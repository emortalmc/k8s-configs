repos=(
  "battle" "blocksumo" "lazertag" "lobby" "marathon" "minesweeper" "parkourtag" "velocity-core"
  "kurushimi" "mc-player-service" "message-handler" "party-manager" "permission-service-go" "relationship-manager-service"
)

for name in "${repos[@]}"
do
  cat ./template.yaml | sed "s|{{name}}|$name|g" | kubectl apply -f -
done

# Tower Defence is in a completely different repository, so it needs a custom repository secret
kubectl apply -f ./tower-defence.yaml
