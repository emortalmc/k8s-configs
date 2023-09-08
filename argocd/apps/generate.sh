names=(
  "battle" "blocksumo" "lazertag" "lobby" "matchmaker" "mc-player-service" "message-handler" "minesweeper" "parkourtag"
  "party-manager" "permission-service" "relationship-manager" "tower-defence" "velocity-core"
)
repos=(
  "battle" "blocksumo" "lazertag" "lobby" "kurushimi" "mc-player-service" "message-handler" "minesweeper" "parkourtag"
  "party-manager" "permission-service-go" "relationship-manager-service" "tower-defence" "velocity-core"
)
staging=$1

file=""
if [ $staging == "true" ]; then
  file="template-staging.yaml"
elif [ $staging == "false" ]; then
  file="template-prod.yaml"
else
  echo "staging must be true or false"
  exit 1
fi

for (( i=0; i<"${#names[@]}"; i++ ))
do
  name="${names[i]}"
  repo="${repos[i]}"
  cat $file | sed "s|{{name}}|$name|g" | sed "s|{{repo}}|$repo|g" | kubectl apply -f -
done
