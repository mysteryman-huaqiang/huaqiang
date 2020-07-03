#!/bin/bash
kube_version=v1.18.5
image_arch=amd64
etcd_version=v3.3.12
opt=$1

google_registry="gcr.io/google-containers"
ali_registry="registry.cn-qingdao.aliyuncs.com/huaqiangk8s"

kube_image_list=(kube-proxy kube-controller-manager kube-apiserver kube-scheduler)


Usage(){
    echo "$0 [save_local|upload_aliyun]"
    echo "save_local: save to local directory $kube_version"
    echo "upload_aliyun: push to registry.cn-qingdao.aliyuncs.com/huaqiangk8s"
}


# download bitch file
down_bitch_file(){
    wget https://storage.googleapis.com/kubernetes-release/release/$kube_version/bin/linux/$image_arch/kubelet
    wget https://storage.googleapis.com/kubernetes-release/release/$kube_version/bin/linux/$image_arch/kubectl
    wget https://storage.googleapis.com/kubernetes-release/release/$kube_version/bin/linux/$image_arch/kubeadm
    wget https://github.com/coreos/etcd/releases/download/$etcd_version/etcd-$etcd_version-linux-$image_arch.tar.gz
}

# download image
download_image(){

    for i in ${kube_image_list[*]}
        do
            docker pull $google_registry/$i:$kube_version
        done
}

# save direcotry
save_image(){

    for i in ${kube_image_list[*]}
        do
            docker save $google_registry/$i:$kube_version -o $i.tar.gz
        done
}



upload_image(){

    for i in ${kube_image_list[*]}
        do
            echo $i
            docker tag $google_registry/$i:$kube_version $ali_registry/$i:$kube_version
            docker push $ali_registry/$i:$kube_version
        done
}

upload_aliyun(){
    download_image
    upload_image
}


save_local(){
    # create direcotry 
    mkdir $kube_version && cd $kube_version
    download_image
    save_image
    down_bitch_file
}

if [[ -z $opt ]];then
    Usage
    exit 102
fi

$opt
