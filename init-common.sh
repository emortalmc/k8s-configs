# Set fs.inotify.max_user_instances (default is 128) to prevent "too many open files" error
cat "fs.inotify.max_user_instances=1024" >> /etc/sysctl.conf

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo "
# EmortalMC Additions Start
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# EmortalMC Additions End" >> ~/.bashrc

source ~/.bashrc

# Add our SSH keys

mkdir -p ~/.ssh
for file in ./sshKeys/*; do
  cat "$file"; echo >> ~/.ssh/authorized_keys
done
