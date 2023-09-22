names=(
  "battle" "blocksumo" "lazertag" "lobby" "marathon" "minesweeper" "parkourtag" "tower-defence" "velocity-core" # Games
  "matchmaker" "mc-player-service" "message-handler" "party-manager" "permission-service" "relationship-manager" # Services
)
# This is a sort of map. The repo name at index i corresponds to the name at index i.
repos=(
  "battle" "blocksumo" "lazertag" "lobby" "marathon" "minesweeper" "parkourtag" "tower-defence" "velocity-core" # Games
  "kurushimi" "mc-player-service" "message-handler" "party-manager" "permission-service-go" "relationship-manager-service" # Services
)

file=""
if [ $STAGING == "true" ]; then
  file="template-staging.yaml"
elif [ $STAGING == "false" ]; then
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
