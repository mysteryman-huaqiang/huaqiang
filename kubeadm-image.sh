#!/bin/bash

ali_registry="registry.cn-qingdao.aliyuncs.com/huaqiangk8s"

a=(
gcr.io/knative-releases/knative.dev/net-istio/cmd/controller@sha256:49bb4cb2224b6d41d07f2259753fd89e8a440cd7bb81eee190faff1e817e7eb9
gcr.io/knative-releases/knative.dev/net-istio/cmd/webhook@sha256:e0b6d3928e6b731f21ca17db2ab9020b42850ce6427fedc4bcb728389ce20ee8
gcr.io/knative-releases/knative.dev/serving/cmd/activator@sha256:69065cec1c1d57d1b16eb448c1abd895c2c554ef0ec19bedd1c14dc3150d2ff1
gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler@sha256:bc1f5dc5594e880dcb126336d8344f0a87cf22075ef32eebd3280e6548ef22ef
gcr.io/knative-releases/knative.dev/serving/cmd/controller@sha256:8b2b5d06ab5b3bbbe0f40393b3e39f6aceb80542d5cfbab97e89758b59b5ef6e
gcr.io/knative-releases/knative.dev/serving/cmd/queue@sha256:0db974f58b48b219ab8047e11b481c2bbda52b7a2d54db5ed58e8659748ec125
gcr.io/knative-releases/knative.dev/serving/cmd/webhook@sha256:e65e11bc8711ed619b346f0385de4d266f59dccf0781fe41a416559b85d414ed
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
