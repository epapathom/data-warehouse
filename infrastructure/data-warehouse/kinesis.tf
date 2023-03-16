resource "aws_kinesis_stream" "data_warehouse_stream" {
  name             = "data-warehouse-stream"
  retention_period = 72

  shard_level_metrics = [
    "IncomingBytes",
    "IncomingRecords",
    "OutgoingBytes",
    "OutgoingRecords",
    "IteratorAgeMilliseconds"
  ]

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}
