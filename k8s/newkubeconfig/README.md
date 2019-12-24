# 1. update file openssl.conf
you must be sure kubernetes apiserver url in this file
# 2. run command shell
```bash
./create.sh /etc/kubernetes/ssl/ca.crt /etc/kubernetes/ssl/ca.key test002 https://192.168.100.20:6443 test002
```
# 3. apply role and rolebinding to kubernetes
```bash
 kubectl apply -f role.yaml
 kubectl apply -f rolebinding.yaml
```
# 4. apply role and rolebinding to kubernetes
```bash
 kubectl get pod --kubeconfig kubeconfig
```

# ps. 
you can update namesapce of role.yaml and rolebinding.yaml to add more privilege