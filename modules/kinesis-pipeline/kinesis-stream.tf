#Create Kinesis stream which will act as the log destination:
resource "aws_kinesis_stream" "isec_stream" {
  name             = "${var.header}-ks"
  shard_count      = var.shardcount
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Environment = var.env
    Project     = var.project
  }
}

