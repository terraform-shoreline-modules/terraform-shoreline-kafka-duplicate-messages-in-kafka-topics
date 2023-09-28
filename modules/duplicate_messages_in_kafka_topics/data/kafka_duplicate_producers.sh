

#!/bin/bash



# Set the Kafka topic name

KAFKA_TOPIC=${TOPIC_NAME}



# Get the list of producers publishing to the topic

PRODUCERS=$(kafka-topics.sh --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} --describe --topic $KAFKA_TOPIC | grep -oP 'ProducerId-\K\d+' | sort | uniq)



# Loop through each producer and check for duplicates

for PRODUCER_ID in $PRODUCERS

do

    DUPLICATE_MESSAGES=$(kafka-run-class.sh kafka.tools.DumpLogSegments --files ${KAFKA_LOG_DIRECTORY}/*.log --producer-threads 1 --deep-iteration --print-data-log --decoder avro --key-decoder avro --value-decoder avro --max-messages 10000000 --message-match "ProducerId=${PRODUCER_ID}" | grep -oP 'offset=\K\d+' | sort | uniq -d)

    

    if [ -z "$DUPLICATE_MESSAGES" ]

    then

        echo "No duplicates found for producer $PRODUCER_ID."

    else

        echo "Duplicates found for producer $PRODUCER_ID: $DUPLICATE_MESSAGES"

    fi

done