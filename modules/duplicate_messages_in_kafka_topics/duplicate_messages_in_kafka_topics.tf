resource "shoreline_notebook" "duplicate_messages_in_kafka_topics" {
  name       = "duplicate_messages_in_kafka_topics"
  data       = file("${path.module}/data/duplicate_messages_in_kafka_topics.json")
  depends_on = [shoreline_action.invoke_kafka_duplicate_checker,shoreline_action.invoke_kafka_consumer_dedup]
}

resource "shoreline_file" "kafka_duplicate_checker" {
  name             = "kafka_duplicate_checker"
  input_file       = "${path.module}/data/kafka_duplicate_checker.sh"
  md5              = filemd5("${path.module}/data/kafka_duplicate_checker.sh")
  description      = "Multiple producers are publishing the same message to the same topic, resulting in duplicates."
  destination_path = "/agent/scripts/kafka_duplicate_checker.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "kafka_consumer_dedup" {
  name             = "kafka_consumer_dedup"
  input_file       = "${path.module}/data/kafka_consumer_dedup.sh"
  md5              = filemd5("${path.module}/data/kafka_consumer_dedup.sh")
  description      = "Implement message deduplication at the consumer end to prevent duplicate messages from being processed."
  destination_path = "/agent/scripts/kafka_consumer_dedup.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_kafka_duplicate_checker" {
  name        = "invoke_kafka_duplicate_checker"
  description = "Multiple producers are publishing the same message to the same topic, resulting in duplicates."
  command     = "`chmod +x /agent/scripts/kafka_duplicate_checker.sh && /agent/scripts/kafka_duplicate_checker.sh`"
  params      = ["ZOOKEEPER_PORT","KAFKA_LOG_DIRECTORY","TOPIC_NAME","ZOOKEEPER_HOST"]
  file_deps   = ["kafka_duplicate_checker"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_duplicate_checker]
}

resource "shoreline_action" "invoke_kafka_consumer_dedup" {
  name        = "invoke_kafka_consumer_dedup"
  description = "Implement message deduplication at the consumer end to prevent duplicate messages from being processed."
  command     = "`chmod +x /agent/scripts/kafka_consumer_dedup.sh && /agent/scripts/kafka_consumer_dedup.sh`"
  params      = ["KAFKA_BROKER_HOST","KAFKA_BROKER_PORT","TOPIC_NAME","CONSUMER_GROUP"]
  file_deps   = ["kafka_consumer_dedup"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_consumer_dedup]
}

