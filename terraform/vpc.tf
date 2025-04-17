/*
Internet
   |
[Internet Gateway] <-- Public Route Table
   |
[Public Subnets] -- (Load Balancer lives here)
   |
[NAT Gateway + EIP] <-- Private Route Table
   |
[Private Subnets] -- (ASG instances with ECS tasks running on them)
*/

# main vpc for the project
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  lifecycle {
    prevent_destroy = true
  }
  tags = merge(var.common_tags, { Name = "${var.project}-vpc" })
}

# igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.project}-igw"
  })
}

# Fetch available AZs dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

# Choose only two of them
locals {
  selected_azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

#---------------------------------PUBLIC SUBNET CONFIG-----------------------------------------------
# Create a public subnet in each AZ
resource "aws_subnet" "public" {
  for_each = toset(local.selected_azs)

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, index(local.selected_azs, each.key))
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    "Name" = "public-subnet-${each.key}",
    "Type" = "public"
  })
}


# Public route table + route to the internet using the igw
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-public-rt"
  })
}

# Associate public route table with public subnets
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

#---------------------------------PRIVATE SUBNET CONFIG-----------------------------------------------
# Create a private subnet in each AZ
resource "aws_subnet" "private" {
  for_each = toset(local.selected_azs)

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, index(local.selected_azs, each.key) + 2)

  tags = merge(var.common_tags, {
    "Name" = "private-subnet-${each.key}",
    "Type" = "private"
  })
}

# NAT gateway in the public subnet + eip for the NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags          = merge(var.common_tags, {
     Name = "${var.project}-nat" 
    })
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(var.common_tags, { Name = "${var.project}-nat-eip" })
}

# Create private route table with outbound route going through the NAT gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-private-rt"
  })
}

# Associate private route with private subnets
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id = each.value.id
  route_table_id = aws_route_table.private.id
}
