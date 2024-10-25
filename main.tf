provider "aws" {
    region = "eu-west-3" # Paris
}

variable "db_password" {
    description = "The password for the RDS PostgreSQL instance"
    type        = string
    sensitive   = true
}

resource "aws_db_instance" "mydatabase" {
    engine               = "postgres"
    engine_version       = "13.15"

    identifier           = "mydatabase"
    db_name              = "mydatabase"

    username             = "postgres"
    password             = var.db_password 

    allocated_storage    = 20 # 20GB is the minimum, otherwise AWS returns an error
    max_allocated_storage = 20
    storage_type         = "gp2"
    instance_class       = "db.t3.micro"

    parameter_group_name = "default.postgres13"
    publicly_accessible  = true

    vpc_security_group_ids = [aws_security_group.postgres.id]

    backup_retention_period = 1
    skip_final_snapshot     = true
}

resource "aws_security_group" "postgres" {
    name = "postgres-security-group"

    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "mydatabase" {
    value = aws_db_instance.mydatabase.endpoint
}
