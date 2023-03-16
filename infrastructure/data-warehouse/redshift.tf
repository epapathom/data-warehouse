resource "aws_redshiftserverless_namespace" "data_warehouse_redshift_namespace" {
  namespace_name      = "data-warehouse-namespace"
  db_name             = "data-warehouse-db"
  admin_username      = var.redshift_admin_username
  admin_user_password = var.redshift_admin_user_password
}

resource "aws_security_group" "data_warehouse_redshift_sg" {
  name        = "data-warehouse-redshift-sg"
  description = "Allow TLS inbound traffic from the ingestion Lambda"
  vpc_id      = var.vpc_id

  ingress {
    description     = "TLS from ingestion Lambda"
    from_port       = 5439
    to_port         = 5439
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

resource "aws_redshiftserverless_workgroup" "data_warehouse_redshift_workgroup" {
  namespace_name       = aws_redshiftserverless_namespace.data_warehouse_redshift_namespace.namespace_name
  workgroup_name       = "data-warehouse-workgroup"
  enhanced_vpc_routing = true
  publicly_accessible  = false
  subnet_ids           = var.private_subnet_ids
  security_group_ids   = [aws_security_group.data_warehouse_redshift_sg.id]
}
