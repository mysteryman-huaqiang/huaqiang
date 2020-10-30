#!/bin/bash

ali_registry="registry.cn-qingdao.aliyuncs.com/huaqiangk8s"

a=(
gcr.io/knative-releases/knative.dev/net-istio/cmd/controller@sha256:49bb4cb2224b6d41d07f2259753fd89e8a440cd7bb81eee190faff1e817e7eb9
gcr.io/knative-releases/knative.dev/net-istio/cmd/webhook@sha256:e0b6d3928e6b731f21ca17db2ab9020b42850ce6427fedc4bcb728389ce20ee8
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
  if [[ "$1" == "" ]];then
    for i in ${a[*]}
      do
          image=`echo $i|awk -F'/' '{print $NF}'`
          docker tag $i $ali_registry/$image
          docker push $ali_registry/$image
      done
  else
    tag=$1
    for i in ${a[*]}
      do
          image=`echo $i|awk -F'/' '{print $NF}'|awk -F'@' '{print $1}'`
          docker tag $i $ali_registry/$image:$tag
          docker push $ali_registry/$image:$tag
      done
  fi
}

if [[ "$1" == "all" ]]; then
docker login --username=ithuaqiang@163.com --password whq8273080 registry.cn-qingdao.aliyuncs.com
pull_image
push_image $2
fi
