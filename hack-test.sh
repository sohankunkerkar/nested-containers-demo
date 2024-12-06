#!/bin/sh
#IP=192.168.1.16
IP=$(hostname -I | cut -d' ' -f1)
echo "Using IP: $IP"
export GOPATH=/home/skunkerk/dev
export KUBE_PATH=$GOPATH/src/k8s.io/kubernetes
export PATH=$PATH:$GOPATH/bin:$KUBE_PATH/third_party/etcd:$KUBE_PATH/_output/local/bin/linux/amd64/
export CONTAINER_RUNTIME=remote
export CGROUP_DRIVER=systemd
export FEATURE_GATES=UserNamespacesSupport=true,ProcMountType=true,UserNamespacesPodSecurityStandards=true
export CONTAINER_RUNTIME_ENDPOINT='unix:///var/run/crio/crio.sock'
export ALLOW_SECURITY_CONTEXT=","
export ALLOW_PRIVILEGED=1
export DNS_SERVER_IP=$IP
export API_HOST=$IP
export API_HOST_IP=$IP
export KUBELET_HOST=$IP
export HOSTNAME_OVERRIDE=$(hostname)
export KUBE_ENABLE_CLUSTER_DNS=false
export ENABLE_HOSTPATH_PROVISIONER=true
export KUBE_ENABLE_CLUSTER_DASHBOARD=true
export KUBELET_FLAGS="--anonymous-auth=true --authorization-mode=AlwaysAllow --config=/tmp/kubelet-config"
export KUBELET_READ_ONLY_PORT="10255"
sudo -E PATH=$PATH hack/local-up-cluster.sh
