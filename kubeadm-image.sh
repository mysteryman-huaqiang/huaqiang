#!/bin/bash

ali_registry="registry.cn-qingdao.aliyuncs.com/huaqiangk8s"

a=(
k8s.gcr.io/kube-apiserver:v1.17.11
k8s.gcr.io/kube-controller-manager:v1.17.11
k8s.gcr.io/kube-scheduler:v1.17.11
k8s.gcr.io/kube-proxy:v1.17.11
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd:3.4.3-0
k8s.gcr.io/coredns:1.6.5
)

Usage(){
    echo "$0 [pull_image|push_image]"
    echo "pull_image: pull image from source"
    echo "push: push image to $ali_registry"
}

pull_image(){
  for i in ${a[*]}
    do
        docker pull $i
    done
}

push_image(){
  for i in ${a[*]}
    do
        image=`echo $i|awk -F'/' '{print $NF}'`
        docker tag $i $ali_registry/$image
        docker push $ali_registry/$image
    done
}

if [[ "$1" == "all" ]]; then
docker login --username=ithuaqiang@163.com --password whq8273080 registry.cn-qingdao.aliyuncs.com
pull_image
push_image
fi