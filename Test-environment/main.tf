# configure aws provider
provider "aws" {
    region  = var.region
    profile = "Terraformecsuser"
}

# create vpc
module "vpc" {
  source                    = "../modules/vpc"
  region                    = var.region
  project_name              = var.project_name
  vpc_cidr                  = var.vpc_cidr
  instance_tenancy          = var.instance_tenancy

  #create subnets
  public_subnet_az1_cidr    = var.public_subnet_az1_cidr
  public_subnet_az2_cidr    = var.public_subnet_az2_cidr
  private_subnet_az1_cidr   = var.private_subnet_az1_cidr

  # create rds
  engine                    = var.engine
  instance_class            = var.instance_class
  db_name                   = var.db_name
  allocated_storage         = var.allocated_storage
  idle_timeout              = var.idle_timeout
  protocol                  = var.protocol
  capacity_provider         = var.capacity_provider
}