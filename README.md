

require:
- either docker or podman
- kind
- helm
- argocd

optionnal:
- kubectx

```bash
kind create cluster --config clusters/deployer.yaml
kind create cluster --config clusters/paris.yaml
kind create cluster --config clusters/tokyo.yaml

k create ns argocd

helm repo add argo-helm https://argoproj.github.io/argo-helm

helm upgrade --install argocd argo-helm/argo-cd --values argocd.yml --namespace argocd

ROOT_PASSWORD=$(k get secrets -n argocd argocd-initial-admin-secret -o jsonpath={.data.password} | base64 --decode)

argocd  login --username admin --password "$ROOT_PASSWORD" 127.0.0.1:8000


function setup_cluster() {
  local cluster_name=$1

  mkdir tmp

  docker cp ${cluster_name}-control-plane:/etc/kubernetes/admin.conf tmp/${cluster_name}-control-plane-kubeconfig.conf

  local cluster_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${cluster_name}-control-plane)

  sed -i "s/${cluster_name}-control-plane:6443/${cluster_ip}:6443/g" tmp/${cluster_name}-control-plane-kubeconfig.conf

  argocd cluster add kubernetes-admin@${cluster_name} --kubeconfig tmp/${cluster_name}-control-plane-kubeconfig.conf --yes
}

setup_cluster "paris"
setup_cluster "tokyo"
```

todo: merge cluster creation
