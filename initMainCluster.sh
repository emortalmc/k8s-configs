TOKEN=$(head -c 1000 /dev/urandom | tr -dc 'a-zA-Z0-9~@^&*_-' | fold -w 128 | head -n 1)
curl -sfL https://get.k3s.io | K3S_TOKEN="$TOKEN" sh -s - server
