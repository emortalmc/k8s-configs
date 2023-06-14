helm upgrade strimzi-kafka strimzi/strimzi-kafka-operator \
  --values 01-values.yaml \
  -n strimzi-system