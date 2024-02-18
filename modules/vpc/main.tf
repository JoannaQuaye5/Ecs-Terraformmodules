provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy = var.instance_tenancy
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name        = "${var.project_name}-vpc"
  }
}

#Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name"        = "${var.project_name}-igw"
  }
}


# use a data source to get all availbility zones in region
data "aws_availability_zones" "available_zones" {}


# Public subnet & avaiability zones
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "public subnet az1"
  }
}


# Public subnet & avaiability zones
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "public subnet az2"
  }
}


# Private subnet & avaiability zones
resource "aws_subnet" "private_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name        = "private subnet az2"
  }
}


# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public_subnet_az1" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "public subnet"
  }
}


# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private_subnet_az2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "private subnet"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_subnet_az1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
  
}


# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public_subnet_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_subnet_az1.id
}

resource "aws_route_table_association" "private_subnet_az2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_subnet_az2.id
}


#aws nat gateway
resource "aws_eip" "Jo_IP" {
    tags = {
      Name = "Jo_IP"
    } 
}
#create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
allocation_id = aws_eip.Jo_IP.id
subnet_id =  aws_subnet.private_subnet_az2.id
}


# NAT Associate with Priv route
resource "aws_route" "private_route" {
route_table_id = aws_route_table.private_subnet_az2.id
gateway_id     = aws_nat_gateway.nat_gateway.id
destination_cidr_block = "0.0.0.0/0"
}


