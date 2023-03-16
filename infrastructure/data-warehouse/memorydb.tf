resource "aws_security_group" "data_warehouse_memorydb_sg" {
  name        = "data-warehouse-memorydb-sg"
  description = "Allow TLS inbound traffic from the ingestion Lambda"
  vpc_id      = var.vpc_id

  ingress {
    description     = "TLS from ingestion Lambda"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.data_warehouse_ingestion_lambda_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_memorydb_subnet_group" "data_warehouse_memorydb_subnet_group" {
  name       = "data-warehouse-memorydb-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_memorydb_cluster" "data_warehouse_memorydb" {
  acl_name                 = "open-access"
  name                     = "data-warehouse-memorydb"
  node_type                = "db.t4g.small"
  security_group_ids       = [aws_security_group.data_warehouse_memorydb_sg.id]
  subnet_group_name        = aws_memorydb_subnet_group.data_warehouse_memorydb_subnet_group.id
  num_shards               = 1
  snapshot_retention_limit = 7
}
