#!/usr/bin/env bash
# shellcheck disable=SC2119,SC2317,SC2317,SC2120

function cert_manager() {
    local action
    action="${1}"

    values(){
        helm template cert-manager/cert-manager
    }

    deploy() {
        std_log "Deploying$GREEN Cert Manager"
        # -f apps/traefik.values.yaml \
        # --wait
        stdbuf -oL helm upgrade \
            --atomic \
            --cleanup-on-fail \
            --install \
            --reset-values \
            --create-namespace \
            --namespace cert-manager \
            --repo=https://charts.jetstack.io \
            --version v1.10.1 \
            --set installCRDs=true \
            --set prometheus.enabled=true \
            --set webhook.timeoutSeconds=4 \
            cert-manager cert-manager | std_buf

        cluster_wait_for_pod "controller" "cert-manager"
        issuer
        stdbuf -oL kubectl get all -n cert-manager | std_buf

        std_success "Deploy done"
    }

    issuer(){
        provider=${1:-$D2K_CONFIG_CLUSTER_MANAGED_DNS_PROVIDER}
        std_info "Installing ${provider} managed DNS issuer"
        case "${provider}" in
        cloudflare)
            kubectl create secret generic cloudflare-api-token \
                -n cert-manager \
                --from-literal=api-token="${D2K_CF_TOKEN}" \
                --dry-run=client -o yaml | kubectl replace --force -f - | std_buf
            issuer_cf_manifest | kubectl apply -f- | std_buf
            ;;
        gcp)
            kubectl create secret generic clouddns-dns01-solver \
                -n cert-manager \
                --from-file=key.json="${D2K_GCP_SERVICE_ACCOUNT}" \
                --dry-run=client -o yaml |
                kubectl replace --force -f - | std_buf
            issuer_gcp_manifest | kubectl apply -f- | std_buf
            ;;
        route53)
            kubectl create secret generic route53-api-secret \
                -n cert-manager \
                --from-literal=secret-access-key="${ROUTE53_SECRET_KEY}" \
                --dry-run=client -o yaml |
                kubectl replace --force -f - | std_buf
            issuer_aws_manifest | kubectl apply -f- | std_buf
            ;;
        selfsigned)
            std_success "A self-signed certificate will be created"
            ;;
        *)
            std_warn "Not installing managed DNS issuer"
            ;;
        esac
        std_success "Issuer configured"
    }    

    issuer_aws_manifest(){
        cat <<EOF
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: d2k-issuer
spec:
  acme:
    email: $LETSENCRYPT_EMAIL
    privateKeySecretRef:
      name: issuer-account-key
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
      - dns01:
          route53:
            region: ${ROUTE53_REGION}
            accessKeyID: ${D2K_ROUTE53_TOKEN}
            secretAccessKeySecretRef:
              name: route53-api-secret
              key: secret-access-key        
EOF
    }

    issuer_gcp_manifest(){
        cat <<EOF
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: d2k-issuer
spec:
  acme:
    email: $LETSENCRYPT_EMAIL
    privateKeySecretRef:
      name: issuer-account-key
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
      - dns01:
          cloudDNS:
            project: $D2K_GCP_PROJECT_ID
            serviceAccountSecretRef:
              name: clouddns-dns01-solver
              key: key.json        
EOF
    }
    issuer_cf_manifest(){
        cat <<EOF
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: d2k-issuer
spec:
  acme:
    email: $D2K_CF_EMAIL
    privateKeySecretRef:
      name: issuer-account-key
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
      - dns01:
          cloudflare:
            email: $D2K_CF_EMAIL
            apiTokenSecretRef:
              name: cloudflare-api-token
              key: api-token
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: d2k-issuer-staging
spec:
  acme:
    email: $D2K_CF_EMAIL
    privateKeySecretRef:
      name: issuer-account-key
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    solvers:
      - dns01:
          cloudflare:
            email: $D2K_CF_EMAIL
            apiTokenSecretRef:
              name: cloudflare-api-token
              key: api-token
EOF
    }

    $action "$@"
}
