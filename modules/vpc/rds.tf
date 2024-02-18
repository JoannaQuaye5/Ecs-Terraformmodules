resource "aws_db_instance" "mydatabase" {
identifier = var.db_name
allocated_storage = var.allocated_storage
storage_type = "gp2"
engine= var.engine
engine_version = "5.7"
instance_class = var.instance_class
username = "adminecs"
password = "adminadmin12"
parameter_group_name = "default.mysql5.7"
publicly_accessible = true
multi_az = false
backup_retention_period = 7
skip_final_snapshot = true

tags = {
Name = "MyDatabase"
}
}