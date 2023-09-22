# Modify Traefik Helm chart values
run_init_script install

# Install internal routes
run_script internal generate.sh

# Install external routes
if [ $STAGING == "true" ]; then
  kubectl apply -f ./external/reposilite.yaml
fi
