#!/bin/bash
#author: hqwang

ca_file=$1
cakey_file=$2
group=$3
apiserver=$4
namespace=$5

Usage(){
    echo " "
    echo "Usage:        $0  ca_file ca_key_file group apiserver namespace"
    echo " "
    echo "ca_file:          kubernetes apiserver ca file, see /etc/kubernetes/ssl/ca.crt"
    echo "ca_key_file:      kubernetes apiserver ca key file, see /etc/kubernetes/ssl/ca.key"
    echo "group:            group name"
    echo "apiserver         kubernetes apiserver url e.g: https://192.168.100.3:6443"
    echo "namespace         kubernetes namespace to grant"
}


if [[ -z $ca_file || -z $cakey_file || -z $group || -z $apiserver || -z $namespace ]];then
    Usage
    exit 102
fi

openssl genrsa -out client-key.pem 2048 > /dev/null 2>&1
openssl req -new -key client-key.pem -out client.csr -subj "/CN=kube-admin-test/O=system:${group}" -config openssl.conf
openssl x509 -req -in client.csr -CA $ca_file -CAkey $cakey_file -CAcreateserial -out client.pem -days 36500 -extensions v3_req -extfile openssl.conf


certificate=`cat $ca_file |base64 |tr -d "\n"`
client=`cat  client.pem|base64 |tr -d "\n"`
client_key=`cat  client-key.pem|base64 |tr -d "\n"`

if [[ ! -d $namespace ]];then
    mkdir $namespace
else
    echo $namespace is exist
    exit
fi

rm -rf client-key.pem client.csr client.pem

cat>./$namespace/kubeconfig <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${certificate}
    server: ${apiserver}
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    namespace: ${namespace}
    user: ${group}-cluster.local
  name: ${group}
current-context: ${group}
kind: Config
preferences: {}
users:
- name: ${group}-cluster.local
  user:
    client-certificate-data: ${client}
    client-key-data: ${client_key}
EOF

cat>./$namespace/role.yaml <<EOF
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
  namespace: ${namespace}
  name: ${group}
rules:
- apiGroups:
  - '*'
  resources: ["pods","deployments","secrets","configmaps","statefulsets","services","persistentvolumeclaims"]
  verbs:
  - '*'
EOF

cat>./$namespace/rolebinding.yaml <<EOF
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  name: ${group}
  namespace: ${namespace}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ${group}
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:${group}
EOF