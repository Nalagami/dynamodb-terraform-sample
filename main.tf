provider "aws" {
  region  = "ap-northeast-1"
}

# terraform {
#   required_version = "~> 1.5.0"
# }


# --------------------------------------------------------
# DynamoDB

resource "aws_dynamodb_table" "members" {
  name           = "samples"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  hash_key       = "id"

  attribute {
    name = "id"
    type = "N"
  }

  tags = {
    Name = "members"
  }
}

# # --------------------------------------------------------
# # DynamoDB Values

locals {
  # json_data = file("./members.json")
  # members    = jsondecode(local.json_data)
  csv_data = file("${path.module}/sample.csv")

  dataset = csvdecode(local.csv_data)
}

resource "aws_dynamodb_table_item" "members" {
  for_each = { for record in local.dataset : record.id => record }

  table_name = aws_dynamodb_table.members.name
  hash_key   = aws_dynamodb_table.members.hash_key

  item = <<EOF
{
  "id": {"N": "${each.value.id}"},
  "name": {"S": "${each.value.name}"},
  "type": {"S": "${each.value.type}"},
  "ability1": {"S": "${each.value.ability1}"},
  "ability2": {"S": "${each.value.ability2}"}
}
EOF
}