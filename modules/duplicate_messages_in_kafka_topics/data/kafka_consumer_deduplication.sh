

#!/bin/bash



# Define Kafka consumer properties

GROUP_ID="${CONSUMER_GROUP}"

TOPIC="${TOPIC_NAME}"



# Start consumer with deduplication

kafka-console-consumer.sh --bootstrap-server ${KAFKA_BROKER_HOST}:${KAFKA_BROKER_PORT} --group $GROUP_ID --topic $TOPIC --property print.key=true --property key.separator=: | awk '!x[$0]++'