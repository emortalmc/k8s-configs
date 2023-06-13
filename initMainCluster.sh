TOKEN=$(head -c 1000 /dev/urandom | tr -dc 'a-zA-Z0-9~@^&*_-' | fold -w 128 | head -n 1)

NODE_NAME=emc-01
ADVERTISE_ADDRESS=65.108.100.154
NODE_IP=65.108.100.154
curl -sfL https://get.k3s.io | K3S_TOKEN="$TOKEN" sh -s - server --flannel-backend=wireguard-native \
  --advertise-address "$ADVERTISE_ADDRESS" \
  --node-name "$NODE_NAME" \
  --node-ip "$NODE_IP"
