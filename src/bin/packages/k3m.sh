#!/usr/bin/env bash

function k3m() {
    # # global environment variables
    # HL_PATH=~/.k3m
    # HL_INSTANCE_USER="ubuntu"
    # HL_INSTANCE_IMAGE="bionic"
    # HL_INSTANCE_NAME="k3m"
    # HL_CLOUD_INIT="cloud-init-k3m.yml"
    # HL_SSH_PRIVATE_KEY=~/.ssh/id_rsa
    # HL_SSH_PUBLIC_KEY=${HL_SSH_PRIVATE_KEY}.pub
    # HL_ENVIRONMENT_FILE=${HL_PATH}/env.sh

    # create k3m home directory
    # mkdir -p ${HL_PATH}

    # check if specified public key exists
    # if [ -f "${HL_SSH_PUBLIC_KEY}" ]; then
    #     # key exists, read content
    #     HL_SSH_PUBLIC_KEY_CONTENT="$(cat ${HL_SSH_PUBLIC_KEY})"

    # else
    #     # key does not exist, create key
    #     echo "Specified key does not exist, creating ssh key ~/.k3m/ssh_key"
    #     ssh-keygen -b 2048 -f ${HL_PATH}/ssh_key -t rsa -C "k3m" -q -N ""
    #     HL_SSH_PRIVATE_KEY=${HL_PATH}/ssh_key
    #     HL_SSH_PUBLIC_KEY=${HL_SSH_PRIVATE_KEY}.pub
    #     HL_SSH_PUBLIC_KEY_CONTENT="$(cat ${HL_SSH_PUBLIC_KEY})"
    # fi

    # generate cloud-config
#     cat >${HL_PATH}/${HL_CLOUD_INIT} <<EOF
# #cloud-config
# ssh_authorized_keys:
#   - ${HL_SSH_PUBLIC_KEY_CONTENT}
# package_update: true
# packages:
#  - curl
# runcmd:
# - curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s -
# EOF


    # deploy multipass instance with generated cloud-config
    echo "Deploying Multipass Instance"
    multipass launch "${HL_INSTANCE_IMAGE}" --name "${HL_INSTANCE_NAME}" --cloud-init "${HL_PATH}/${HL_CLOUD_INIT}"

    # get the ipv4 address of the multipass instance
    echo "Getting the IPv4 Address of ${HL_INSTANCE_NAME}"
    export HL_INSTANCE_IP=$(multipass info ${HL_INSTANCE_NAME} | grep IPv4 | awk '{print $2}')

    # wait until the kubernetes port is listening
    while [ "${EXIT_CODE}" != 0 ]; do
        sleep 1
        nc -vz -w1 ${HL_INSTANCE_IP} 6443 &>/dev/null && EXIT_CODE=${?} || EXIT_CODE=${?}
    done

    # get the kubeconfig from the multipass instance, replace the localhost ip with the multipass ipv4 address and save to k3m path locally
    echo "Writing the kubeconfig to ${HL_PATH}/kubeconfig"
    multipass transfer ${HL_INSTANCE_NAME}:/etc/rancher/k3s/k3s.yaml ${HL_PATH}/kubeconfig
    sed -i '' "s/127.0.0.1/${HL_INSTANCE_IP}/g" ${HL_PATH}/kubeconfig

    # save env vars to file
    echo "Writing the environment file to ${HL_ENVIRONMENT_FILE}"
    echo "export HL_PATH=${HL_PATH}" >${HL_ENVIRONMENT_FILE}
    echo "export HL_INSTANCE_USER=${HL_INSTANCE_USER}" >>${HL_ENVIRONMENT_FILE}
    echo "export HL_INSTANCE_NAME=${HL_INSTANCE_NAME}" >>${HL_ENVIRONMENT_FILE}
    echo "export HL_CLOUD_INIT=${HL_PATH}/${HL_CLOUD_INIT}" >>${HL_ENVIRONMENT_FILE}
    echo "export HL_SSH_PRIVATE_KEY=${HL_SSH_PRIVATE_KEY}" >>${HL_ENVIRONMENT_FILE}
    echo alias k3m=\"multipass exec ${HL_INSTANCE_NAME} -- $\{1}\" >>${HL_ENVIRONMENT_FILE}
    echo alias k3m-delete=\"multipass delete --purge ${HL_INSTANCE_NAME}\" >>${HL_ENVIRONMENT_FILE}

    # write banner info to file
    echo "Writing the banner info to ${HL_PATH}/banner"
    echo "" >${HL_PATH}/banner
    echo "Welcome to:" >>${HL_PATH}/banner
    echo "" >>${HL_PATH}/banner
    echo "    __    ____      " >>${HL_PATH}/banner
    echo "   / /__ |_  /__ _  " >>${HL_PATH}/banner
    echo "  /  '_/_/_ </  ' \ " >>${HL_PATH}/banner
    echo " /_/\_\/____/_/_/_/ " >>${HL_PATH}/banner
    echo "" >>${HL_PATH}/banner

    echo "
To access Kubernetes:
---------------------
export KUBECONFIG=${HL_PATH}/kubeconfig
kubectl get nodes -o wide
To SSH to your Multipass Instance:
---------------------------------
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i ${HL_SSH_PRIVATE_KEY} ubuntu@${HL_INSTANCE_IP}
If you don't have kubectl installed:
-----------------------------------
source ${HL_ENVIRONMENT_FILE}
k3m kubectl get nodes -o wide
To destroy the environment:
---------------------------
k3m-delete
" >>${HL_PATH}/banner

    echo "Deployment completed"
    echo ""
    sleep 1

    cat ${HL_PATH}/banner
}
