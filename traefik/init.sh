# Modify Traefik Helm chart values
run_init_script install

# Install internal routes
run_script external generate.sh

# Install external routes
if [ "$STAGING" == "false" ]; then
  kubectl apply -f ./external/reposilite.yaml
fi
