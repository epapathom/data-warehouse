data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "data_warehouse_ingestion_lambda_role" {
  name               = "data-warehouse-ingestion-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name = "data-warehouse-ingestion-lambda-inline-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeInstances",
            "ec2:AttachNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses",
            "kinesis:GetRecords",
            "kinesis:GetShardIterator",
            "kinesis:DescribeStream",
            "kinesis:ListShards",
            "kinesis:ListStreams",
            "redshift-serverless:GetCredentials",
            "redshift-data:ExecuteStatement",
            "redshift-data:ListDatabases",
            "redshift-data:ListSchemas",
            "redshift-data:ListTables",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}
