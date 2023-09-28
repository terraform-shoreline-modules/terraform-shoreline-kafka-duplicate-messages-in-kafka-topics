
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Duplicate Messages in Kafka Topics
---

Duplicate messages in Kafka topics occur when one or more identical messages are written to the same Kafka topic. This can happen due to various reasons such as incorrect configuration of producers and consumers, network issues, or software bugs. Duplicate messages can cause issues in the downstream systems that consume data from Kafka topics, leading to data inconsistencies and other problems. It is important to monitor Kafka topics for duplicate messages and take appropriate measures to prevent them.

### Parameters
```shell
export ZOOKEEPER_PORT="PLACEHOLDER"

export ZOOKEEPER_HOST="PLACEHOLDER"

export TOPIC_NAME="PLACEHOLDER"

export CONSUMER_GROUP="PLACEHOLDER"

export KAFKA_BROKER_PORT="PLACEHOLDER"

export KAFKA_BROKER_HOST="PLACEHOLDER"

export KAFKA_LOG_DIRECTORY="PLACEHOLDER"
```

## Debug

### Check if Kafka is running
```shell
systemctl status kafka.service
```

### List topics in Kafka
```shell
kafka-topics.sh --list --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT}
```

### Check the number of replicas for a specific topic
```shell
kafka-topics.sh --describe --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} --topic ${TOPIC_NAME}
```

### Check the number of partitions for a specific topic
```shell
kafka-topics.sh --describe --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} --topic ${TOPIC_NAME}
```

### Check the consumer groups and their offsets for a specific topic
```shell
kafka-consumer-groups.sh --bootstrap-server ${KAFKA_BROKER_HOST}:${KAFKA_BROKER_PORT} --describe --group ${CONSUMER_GROUP} --topic ${TOPIC_NAME}
```

### Check the Kafka logs for errors or warnings
```shell
tail -f /var/log/kafka/kafka.log
```

### Multiple producers are publishing the same message to the same topic, resulting in duplicates.
```shell


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


```

## Repair

### Implement message deduplication at the consumer end to prevent duplicate messages from being processed.
```shell


#!/bin/bash



# Define Kafka consumer properties

GROUP_ID="${CONSUMER_GROUP}"

TOPIC="${TOPIC_NAME}"



# Start consumer with deduplication

kafka-console-consumer.sh --bootstrap-server ${KAFKA_BROKER_HOST}:${KAFKA_BROKER_PORT} --group $GROUP_ID --topic $TOPIC --property print.key=true --property key.separator=: | awk '!x[$0]++'


```