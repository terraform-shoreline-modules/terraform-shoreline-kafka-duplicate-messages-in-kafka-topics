terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "duplicate_messages_in_kafka_topics" {
  source    = "./modules/duplicate_messages_in_kafka_topics"

  providers = {
    shoreline = shoreline
  }
}