# ArgoCD CRDs
kubectl create -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.7.6"

# Strimzi (Kafka) CRDs
kubectl create -f "https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.35.1/strimzi-crds-0.35.1.yaml"

# MongoDB Community Operator CRDs
kubectl create -k "https://github.com/mongodb/mongodb-kubernetes-operator/config/crd?ref=v0.8.0"

# Prom Stack CRDs
function install_prom_stack_crds {
  base_url="https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-47.0.0/charts/kube-prometheus-stack/crds"
  kubectl create -f "$base_url/crd-alertmanagerconfigs.yaml"
  kubectl create -f "$base_url/crd-alertmanagers.yaml"
  kubectl create -f "$base_url/crd-podmonitors.yaml"
  kubectl create -f "$base_url/crd-probes.yaml"
  kubectl create -f "$base_url/crd-prometheusagents.yaml"
  kubectl create -f "$base_url/crd-prometheuses.yaml"
  kubectl create -f "$base_url/crd-prometheusrules.yaml"
  kubectl create -f "$base_url/crd-scrapeconfigs.yaml"
  kubectl create -f "$base_url/crd-servicemonitors.yaml"
  kubectl create -f "$base_url/crd-thanosrulers.yaml"
}
install_prom_stack_crds
