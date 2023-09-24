node_name=$1
address=$2

token=$(head -c 1000 /dev/urandom | tr -dc 'a-zA-Z0-9~@^&*_-' | fold -w 128 | head -n 1)

if [ -z "$node_name" ]; then
  echo "Node name not provided"
  exit 1
fi
if [ -z "$address" ]; then
  echo "Address not provided"
  exit 1
fi

curl -sfL https://get.k3s.io | K3S_TOKEN="$token" sh -s - server \
  --flannel-backend=wireguard-native \
  --advertise-address "$address" \
  --node-name "$node_name" \
  --node-ip "$address" \
  --resolv-conf /run/systemd/resolve/resolv.conf # All systems are installed with Ubuntu so this is necessary

./init-common.sh

# Install Linkerd as it must be run on the server

source ./utils.sh

run_init_script linkerd
