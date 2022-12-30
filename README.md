# homelab-dev

| [Power up your Linux developer environment](https://blog.raphaelcarlosr.dev/power-up-your-linux-developer-environment)

| `./homelab.sh --name test --path ~/homelab  --domain homelab.localhost`

## Variables

| **Variable** 	| **Default** 	| **description** 	|
|---	|---	|---	|
| D2K_CONFIG_ENV_PATH 	| ~/.homelab 	| Home lab bin path 	|
| D2K_NAME 	| homelab-cluster 	| Home lab name 	|
| D2K_FQDN_DOMAIN 	| homelab.localhost 	| Your domain 	|
| D2K_SSH_PRIVATE_KEY 	| **${D2K_CONFIG_ENV_PATH}**/.ssh 	| Homelab ssh private key 	|
| D2K_SSH_PUBLIC_KEY 	| **${D2K_SSH_PRIVATE_KEY}**.pub 	| Homelab ssh public key 	|

| The ssl key is auto generated if not exists, and you can delete anytime. It's used in multipass vms

## Cluster

`cluster [action] [provider] [options]`

### Actions

- **create** Create new cluster
- **delete** Delete cluster
- **start** Start a created cluster
- **stop** Stop a created cluster
- **info** Print cluster info
- **kubectl** Get cluster kubeclt

### Providers

- **k3d** Create k3d cluster
- **multipass-k3d** Create multipass-k3d cluster
- **multipass-k3sup** Create multipass-k3sup cluster
- **multipass-microk8s** Create multipass-microk8s cluster
- **kind** Create kind cluster

### Options

| **option** 	| **default** 	| **description** 	|
|---	|---	|---	|
| **-n\|--name** 	| **$D2K_NAME** variable | Cluster name 	|
| **-d\|--domain** 	| **$D2K_FQDN_DOMAIN** variable 	| Cluster domain to external access |
| **-p\|--port** 	| 5510 	| Cluster api port |
| **-ip\|--ip** 	| **${D2K_CURRENT_EXTERNAL_IP}** variable    | Cluster api port  |
| **-hp\|--http-port** 	| 80    | Cluster **http** port  |
| **-hs\|--https-port** 	| 443    | Cluster **https** port  |
| **-cp\|--control-planes** 	| 1    | Number of control planes in clusters  |
| **-w\|--workers** 	| 1    | Number of workers in clusters  |
| **-pv\|--persistent-volume** 	| 10    | Size in **Gi** of cluster volume  |

## Tools

- [https://github.com/kubescape/kubescape]

## Apps

- [https://devtron.ai/]
- [https://cerbos.dev/]
- [https://www.passbolt.com/]
- [https://nucleussec.com/]
- [https://www.passkeys.io/]
- [https://appmap.io/]
- [https://infisical.com/]
- [https://github.com/nektos/act]
- [https://kube-vip.io/]
- [https://www.kasten.io/kubernetes/open-source]
- [https://amplication.com/]
- [https://github.com/openblocks-dev/openblocks]
- [https://budibase.com/self-host/]
- [https://www.passkeys.io/]
- [https://verdaccio.org/]

## References

- [X] [https://gitlab.com/linuxshots/spinup-k8s/]
- [X] [https://github.com/rajasoun/multipass-wrapper/blob/main/src/common/multipass.bash]
- [X] [https://github.com/ruanbekker/k3m/]
- [] [https://gist.github.com/mtthlm/8847025]
- [] [https://gist.github.com/irazasyed/a7b0a079e7727a4315b9]
- [] [https://www.publish0x.com/awesome-self-hosted/traefik-on-k3s-xgpwevl]
- [] [https://github.com/arashkaffamanesh/kubeadm-multipass]
- [] [https://github.com/natemellendorf/kubernetes]
- [] [https://github.com/PhilippeVienne/terraform-k3d-metallb]
- [] [https://github.com/coolexplorer/k8s-charts/tree/main/k8s]
- [] [https://unix.stackexchange.com/questions/225179/display-spinner-while-waiting-for-some-process-to-finish/225183#225183]
- [] [https://gist.github.com/A1994SC/5279001869168aea95108e860517f3e4]
- [] [https://blog.marcolancini.it/2021/blog-kubernetes-lab-cloudflare-tunnel/]
- [] [https://github.com/kurokobo/awx-on-k3s/tree/main/builder]
- [] [https://github.com/AbsaOSS/k3d-action]
- [] [https://github.com/nolar/setup-k3d-k3s]
- [] [https://github.com/cnrancher/autok3s]
- [] [https://github.com/k3d-io/vscode-k3d]
- [] [https://devnetstack.com/deploy-local-kubernetes-development-cluster-with-k3d-and-istio-service-mesh/]
- [] [https://ddymko.medium.com/traefik-with-lets-encrypt-and-docker-af24d2ed3535]
- [] [https://docs.openblocks.dev/self-hosting]
- [] [https://medium.com/geekculture/creating-your-own-free-and-secure-cloud-lab-using-oracle-cloud-kubernetes-traefik-and-rancher-efadd4c65975]
- [] [https://github.com/Kapernikov/skaffold-helm-tutorial/blob/main/chapters/08-ingress.md]
- [] [https://ian-says.com/articles/k3d-k8s-kubernetes/]
- [] [https://medium.com/linux-shots/spin-up-a-lightweight-kubernetes-cluster-on-linux-with-k3s-metallb-and-nginx-ingress-167d98f3583d]
- [] [https://github.com/kubernauts/bonsai/blob/master/2-deploy-k3s.sh]
- [] [https://github.com/mrsimonemms/gitpod-k3s-guide/blob/main/setup.sh]
- [] [https://github.com/scaamanho/k3d-cluster]
- [] [https://gist.github.com/pdxjohnny/a930742dae23ac43e230a3f6ad25dee9]
- [] [https://blog.internetz.me/posts/my-road-to-self-hosted-kubernetes-with-k3s_logging-with-efk/]
- [] [https://dev.to/ordigital/cloudflare-ddns-on-linux-4p0d]
- [] [https://holmq.dk/post/2022-04-08-cloudflare-ddns-bash-script/]
- [] [https://itnext.io/using-cloudflare-tunnels-to-securely-expose-kubernetes-services-26713fb5da0a]
- [] [https://ilayk.com/2022/09/23/cloudflare-tunnel-as-a-kubernetes-deployment-ingress]
- [] [https://github.com/matti/k3sup-multipass/blob/master/bin/k3sup-multipass]
    - [https://github.com/tomowatt/k3s-multipass-bootstrap]
- [] [https://dev.to/tomowatt/creating-a-k3s-cluster-with-k3sup-multipass-h26]
- [] [https://rpi4cluster.com/k3s/k3s-traefik/]
- [] [https://www.suse.com/c/rancher_blog/implementing-gitops-on-kubernetes-using-k3s-rancher-vault-and-argo-cd/]
- [] [https://medium.com/nerd-for-tech/github-actions-self-hosted-runner-on-kubernetes-55d077520a31]
- [] [https://www.fullstaq.com/knowledge-hub/blogs/setting-up-your-own-k3s-home-cluster]
- [] [https://blog-alexellis-io.cdn.ampproject.org/v/s/blog.alexellis.io/bare-metal-kubernetes-with-k3s/amp/?amp_gsa=1&amp_js_v=a9&usqp=mq331AQKKAFQArABIIACAw%3D%3D#amp_tf=From%20%251%24s&aoh=16710718831584&referrer=https%3A%2F%2Fwww.google.com&ampshare=https%3A%2F%2Fblog.alexellis.io%2Fbare-metal-kubernetes-with-k3s%2F]
- [] [https://gist.github.com/thebsdbox/752a209fc86ea243ab33b85e8686f718]
- [] [https://www.smarthomebeginner.com/cloudflare-settings-for-traefik-docker/]
- [] [https://github.com/digitalis-io/k3s-on-prem-production]
- [] [https://michael-tissen.medium.com/backup-your-raspberry-pi-cluster-with-velero-d13bf914b8a2]
- [https://gabrieltanner-org.cdn.ampproject.org/v/s/gabrieltanner.org/blog/ha-kubernetes-cluster-using-k3s/amp/?amp_gsa=1&amp_js_v=a9&usqp=mq331AQKKAFQArABIIACAw%3D%3D#amp_tf=From%20%251%24s&aoh=16711597321742&referrer=https%3A%2F%2Fwww.google.com&ampshare=https%3A%2F%2Fgabrieltanner.org%2Fblog%2Fha-kubernetes-cluster-using-k3s%2F]
- [https://github.com/traefik-workshops/traefik-workshop/blob/master/README.md]
- [https://github.com/filipweilid/k3s-homelab]
- [https://github.com/scaamanho/k3d-cluster/blob/master/k3d-cluster]
- [https://github.com/mrsimonemms/gitpod-k3s-guide/blob/main/setup.sh]

- [https://github.com/gangefors/local-k3s-cluster]
- [https://gist.github.com/pdxjohnny/a930742dae23ac43e230a3f6ad25dee9]
- [https://levelup.gitconnected.com/kubernetes-cluster-with-k3s-and-multipass-7532361affa3]
- -------------
- [https://www.suse.com/c/rancher_blog/implementing-gitops-on-kubernetes-using-k3s-rancher-vault-and-argo-cd/]
- [https://rpi4cluster.com/k3s/k3s-traefik/]
- [https://dev.to/tomowatt/creating-a-k3s-cluster-with-k3sup-multipass-h26]
- [https://github.com/matti/k3sup-multipass/blob/master/bin/k3sup-multipass]
- [https://blog.internetz.me/posts/my-road-to-self-hosted-kubernetes-with-k3s_logging-with-efk/]
- [https://gist.github.com/pdxjohnny/a930742dae23ac43e230a3f6ad25dee9]
- [https://github.com/kubernauts/bonsai/blob/master/2-deploy-k3s.sh]
- [https://medium.com/linux-shots/spin-up-a-lightweight-kubernetes-cluster-on-linux-with-k3s-metallb-and-nginx-ingress-167d98f3583d]
- [https://github.com/Kapernikov/skaffold-helm-tutorial/blob/main/chapters/08-ingress.md]
- [https://ian-says.com/articles/k3d-k8s-kubernetes/]
- [https://medium.com/geekculture/creating-your-own-free-and-secure-cloud-lab-using-oracle-cloud-kubernetes-traefik-and-rancher-efadd4c65975]
- [https://ddymko.medium.com/traefik-with-lets-encrypt-and-docker-af24d2ed3535]
- [https://github.com/jsiebens/k3s-on-gcp/]
- [https://nimblehq.co/blog/provision-k3s-on-google-cloud-with-terraform-and-k3sup]
- [https://github.com/3scale-labs/kloud]
- [https://www.suse.com/c/rancher_blog/set-up-your-k3s-cluster-for-high-availability-on-digitalocean/]
- [https://johansiebens.dev/posts/2020/11/provision-a-multi-region-k3s-cluster-on-google-cloud-with-terraform/]

