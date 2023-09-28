resource "shoreline_notebook" "duplicate_messages_in_kafka_topics" {
  name       = "duplicate_messages_in_kafka_topics"
  data       = file("${path.module}/data/duplicate_messages_in_kafka_topics.json")
  depends_on = [shoreline_action.invoke_kafka_duplicate_producers,shoreline_action.invoke_kafka_consumer_deduplication]
}

resource "shoreline_file" "kafka_duplicate_producers" {
  name             = "kafka_duplicate_producers"
  input_file       = "${path.module}/data/kafka_duplicate_producers.sh"
  md5              = filemd5("${path.module}/data/kafka_duplicate_producers.sh")
  description      = "Multiple producers are publishing the same message to the same topic, resulting in duplicates."
  destination_path = "/agent/scripts/kafka_duplicate_producers.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "kafka_consumer_deduplication" {
  name             = "kafka_consumer_deduplication"
  input_file       = "${path.module}/data/kafka_consumer_deduplication.sh"
  md5              = filemd5("${path.module}/data/kafka_consumer_deduplication.sh")
  description      = "Implement message deduplication at the consumer end to prevent duplicate messages from being processed."
  destination_path = "/agent/scripts/kafka_consumer_deduplication.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_kafka_duplicate_producers" {
  name        = "invoke_kafka_duplicate_producers"
  description = "Multiple producers are publishing the same message to the same topic, resulting in duplicates."
  command     = "`chmod +x /agent/scripts/kafka_duplicate_producers.sh && /agent/scripts/kafka_duplicate_producers.sh`"
  params      = ["ZOOKEEPER_PORT","ZOOKEEPER_HOST","KAFKA_LOG_DIRECTORY","TOPIC_NAME"]
  file_deps   = ["kafka_duplicate_producers"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_duplicate_producers]
}

resource "shoreline_action" "invoke_kafka_consumer_deduplication" {
  name        = "invoke_kafka_consumer_deduplication"
  description = "Implement message deduplication at the consumer end to prevent duplicate messages from being processed."
  command     = "`chmod +x /agent/scripts/kafka_consumer_deduplication.sh && /agent/scripts/kafka_consumer_deduplication.sh`"
  params      = ["CONSUMER_GROUP","KAFKA_BROKER_HOST","KAFKA_BROKER_PORT","TOPIC_NAME"]
  file_deps   = ["kafka_consumer_deduplication"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_consumer_deduplication]
}

