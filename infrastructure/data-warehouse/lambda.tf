resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = <<-EOT
    mkdir data_warehouse_ingestion_lambda
    cd data_warehouse_ingestion_lambda
    cp -r ../../../ingestion-lambda/ .
    pip install -r requirements.txt -t .
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

data "archive_file" "data_warehouse_ingestion_lambda_zip" {
  type        = "zip"
  source_dir  = "data_warehouse_ingestion_lambda"
  output_path = "data_warehouse_ingestion_lambda.zip"

  depends_on = [
    null_resource.install_dependencies
  ]
}

resource "aws_security_group" "data_warehouse_ingestion_lambda_sg" {
  name        = "data-warehouse-ingestion-lambda-sg"
  description = "Allow only outbound traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lambda_function" "data_warehouse_ingestion_lambda" {
  filename      = "data_warehouse_ingestion_lambda.zip"
  function_name = "data-warehouse-ingestion-lambda"
  handler       = "main.handler"
  role          = aws_iam_role.data_warehouse_ingestion_lambda_role.arn

  runtime     = "python3.9"
  memory_size = 128

  source_code_hash = data.archive_file.data_warehouse_ingestion_lambda_zip.output_base64sha256

  vpc_config {
    security_group_ids = [aws_security_group.data_warehouse_ingestion_lambda_sg.id]
    subnet_ids         = var.private_subnet_ids
  }

  environment {
    variables = {
      MEMORYDB_HOST           = aws_memorydb_cluster.data_warehouse_memorydb.cluster_endpoint[0].address
      REDSHIFT_WORKGROUP_NAME = aws_redshiftserverless_workgroup.data_warehouse_redshift_workgroup.id
      REDSHIFT_DATABASE_NAME  = aws_redshiftserverless_namespace.data_warehouse_redshift_namespace.db_name
      REDSHIFT_TABLE_NAME     = var.redshift_table_name
    }
  }
}

resource "aws_lambda_event_source_mapping" "data_warehouse_ingestion_lambda_event_source" {
  event_source_arn  = aws_kinesis_stream.data_warehouse_stream.arn
  function_name     = aws_lambda_function.data_warehouse_ingestion_lambda.arn
  starting_position = "LATEST"
}
