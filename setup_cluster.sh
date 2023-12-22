function setup_cluster() {
  cluster_name=$1
  container_cli=${CONTAINER_CLI:-docker}

  mkdir tmp

  # The kubeconfig file needs to be gathered from the container
  $container_cli cp ${cluster_name}-control-plane:/etc/kubernetes/admin.conf tmp/${cluster_name}-control-plane-kubeconfig.conf

  # Since the IP address for an external caller will not be localhost,
  # the container IP address has to be resolved and replaced in the kubeconfig file
  local cluster_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${cluster_name}-control-plane)
  sed -i "s/${cluster_name}-control-plane:6443/${cluster_ip}:6443/g" tmp/${cluster_name}-control-plane-kubeconfig.conf

  # Finally, the argocd CLI is used to register the cluster
  argocd cluster add kubernetes-admin@${cluster_name} --kubeconfig tmp/${cluster_name}-control-plane-kubeconfig.conf --yes
}
