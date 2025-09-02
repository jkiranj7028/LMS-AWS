data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.project_name}-igw" }
}

resource "aws_subnet" "public" {
  for_each = toset(slice(data.aws_availability_zones.available.names, 0, length(var.public_subnets)))
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[index(toset(var.public_subnets), var.public_subnets[index(slice(var.public_subnets,0,length(var.public_subnets)), index(keys(each),0))])] # keep stable
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_name}-public-${each.key}" }
}

resource "aws_subnet" "private" {
  for_each = toset(slice(data.aws_availability_zones.available.names, 0, length(var.private_subnets)))
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[index(toset(var.private_subnets), var.private_subnets[index(slice(var.private_subnets,0,length(var.private_subnets)), index(keys(each),0))])]
  availability_zone = each.key
  tags = { Name = "${var.project_name}-private-${each.key}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
