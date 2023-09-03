repos=(
  "battle" "blocksumo" "lazertag" "lobby" "kurushimi" "mc-player-service" "message-handler" "minesweeper"
  "parkourtag" "party-manager" "permission-service-go" "relationship-manager-service" "velocity-core"
)

for name in "${repos[@]}"
do
  cat ./template.yaml | sed "s|{{name}}|$name|g" | kubectl apply -f -
done
