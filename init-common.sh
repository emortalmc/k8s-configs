# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo "
# EmortalMC Additions Start
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# EmortalMC Additions End" >> ~/.bashrc

source ~/.bashrc
