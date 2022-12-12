#!/usr/bin/env bash

function cluster_cli() {
    opt="$2"
    action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
    std_header "Cluster ${action}"
    case $action in
    k3d) 
    k3d_cli "$@" 
    ;;
    *)
        std_info "Usage"
        ;;
    esac
}

function wait_for_pod(){
    # local _pod, _namespace
    _pod=$1
    _namespace=${2:-default}
    std_log "Waiting for pod ($GREEN${_namespace}:${_pod}$BLUE) up"
    until [[ $(kubectl get pods -n "${_namespace}" -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\t"}{.status.containerStatuses[*].name}{"\n"}{end}' | grep "${_pod}" | awk -F " " '{print $1}') = 'True' ]]; do
        spin
    done
    endspin
}

# function _multipass() {
#     opt="$2"
#     action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
#     case $action in
#     setup)
#         check_preconditions
#         display_runnning_vms "$action"
#         get_vm_name
#         echo "CPU:$CPU | MEMORY:$MEMORY | DISK:$DISK"
#         setup "$VM_NAME"
#         ;;
#     up)
#         display_runnning_vms "$action"
#         get_vm_name
#         multipass start "$VM_NAME"
#         ;;
#     upgrade)
#         display_runnning_vms "$action"
#         get_vm_name
#         upgrade "$VM_NAME"
#         ;;
#     down)
#         display_runnning_vms "$action"
#         get_vm_name
#         multipass stop "$VM_NAME"
#         ;;
#     shell)
#         display_runnning_vms "$action"
#         get_vm_name
#         multipass shell "$VM_NAME"
#         ;;
#     status)
#         display_runnning_vms "$action"
#         get_vm_name
#         multipass info "$VM_NAME"
#         ;;
#     clean)
#         display_runnning_vms "$action"
#         get_vm_name
#         multipass stop "$VM_NAME" && multipass delete "$VM_NAME" && multipass purge
#         ;;
#     *)
#         echo "${RED}Usage: ./assist <command>${NC}"
#         cat <<-EOF
# Commands:
# ---------
#   setup               -> Setup VM
#   up                  -> Bring Up VM
#   upgrade             -> Upgrade VM
#   down                -> Bring Down VM
#   shell               -> Enter Shell
#   status              -> Status of all multipass VMs
#   clean               -> Clean & Destroy VM
# EOF
#         ;;
#     esac
# }

# function _k3d() {
#     opt="$2"
#     action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
#     case $action in
#     setup)
#         #_multipass "$@"
#         multipass exec "$VM_NAME" -- curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash || echo "k3d install ❌"
#         multipass exec "$VM_NAME" -- k3d cluster create microk3s
#         ;;
#     status)
#         _multipass "$@"
#         ;;
#     pods)
#         kubectl get pods --all-namespaces || echo "pods  ❌"
#         ;;
#     dashboard)
#         secret=$(multipass exec "$VM_NAME" -- sudo kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
#         token=$(multipass exec "$VM_NAME" -- sudo kubectl -n kube-system describe secret "$secret" | grep token:)
#         IP=$(multipass info "$VM_NAME" | grep IPv4 | awk '{ print $2 }')

#         multipass exec "$VM_NAME" -- sudo kubectl port-forward -n kube-system service/kubernetes-dashboard \
#             10443:443 --address 0.0.0.0 >/dev/null 2>&1 &
#         echo "Dashboard URL: https://$IP:10443"
#         echo "$token"
#         ;;
#     clean)
#         _multipass "$@"
#         ;;
#     *)
#         echo "${RED}Usage: ./assist <command>${NC}"
#         cat <<-EOF
# Commands:
# ---------
#   setup       -> Install and Configure microk8s
#   dashboard   -> Access k8s Dashboard
#   pods        -> List Running PODs
#   clean       -> Clean multipass VM
# EOF
#         ;;
#     esac
# }

# function _microk8s() {
#     opt="$2"
#     action=$(tr '[:upper:]' '[:lower:]' <<<"$opt")
#     case $action in
#     setup)
#         _multipass "$@"
#         multipass exec "$VM_NAME" -- sudo snap install microk8s --classic || echo "microk8s install ❌"
#         multipass exec "$VM_NAME" -- sudo iptables -P FORWARD ACCEPT || echo "iptables update ❌"
#         multipass exec "$VM_NAME" -- sudo usermod -a -G microk8s ubuntu || echo "usermod  ❌"
#         multipass exec "$VM_NAME" -- sudo snap alias microk8s.kubectl kubectl || echo "snap alias  ❌"
#         multipass exec "$VM_NAME" -- microk8s status --wait-ready || echo "status  ❌"
#         multipass exec "$VM_NAME" -- microk8s start || echo "microk8s start  ❌"
#         multipass exec "$VM_NAME" -- microk8s enable dashboard || echo "dashboard  ❌"
#         multipass exec "$VM_NAME" -- kubectl get pods --all-namespaces || echo "pods  ❌"
#         multipass exec "$VM_NAME" -- kubectl cluster-info || echo "cluster info  ❌"

#         # multipass exec "$VM_NAME" -- sudo chown -f -R ubuntu ~/.kube || echo "chown  ❌"
#         token=$(multipass exec "$VM_NAME" -- kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
#         multipass exec "$VM_NAME" -- kubectl -n kube-system describe secret "$token" || echo "secret  ❌"
#         # enable kubeconfig on host system
#         multipass exec "$VM_NAME" -- microk8s config >kubeconfig/.admin.kubeconfig || echo "kubeconfig  ❌"
#         ;;
#     status)
#         _multipass "$@"
#         ;;
#     pods)
#         kubectl get pods --all-namespaces || echo "pods  ❌"
#         ;;
#     dashboard)
#         secret=$(multipass exec "$VM_NAME" -- sudo kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
#         token=$(multipass exec "$VM_NAME" -- sudo kubectl -n kube-system describe secret "$secret" | grep token:)
#         IP=$(multipass info "$VM_NAME" | grep IPv4 | awk '{ print $2 }')

#         multipass exec "$VM_NAME" -- sudo kubectl port-forward -n kube-system service/kubernetes-dashboard \
#             10443:443 --address 0.0.0.0 >/dev/null 2>&1 &
#         echo "Dashboard URL: https://$IP:10443"
#         echo "$token"
#         ;;
#     clean)
#         _multipass "$@"
#         ;;
#     *)
#         echo "${RED}Usage: ./assist <command>${NC}"
#         cat <<-EOF
# Commands:
# ---------
#   setup       -> Install and Configure microk8s
#   dashboard   -> Access k8s Dashboard
#   pods        -> List Running PODs
#   clean       -> Clean multipass VM
# EOF
#         ;;
#     esac
# }
