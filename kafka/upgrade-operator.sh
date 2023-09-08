helm upgrade strimzi-kafka strimzi/strimzi-kafka-operator \
  --values values.yaml --version 0.37.0 \
  -n strimzi-system
