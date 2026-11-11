resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-vpc"
    Environment = "${var.environment}"
    ManagedBy = "terraform"
  }
}

resource "aws_subnet" "public_subnet" {
  for_each = var.public_subnet
  vpc_id = aws_vpc.main.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
}

resource "aws_subnet" "private_subnet" {
  for_each = var.private_subnet
  vpc_id = aws_vpc.main.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-igw"
    Environment = "${var.environment}"
    ManagedBy = "terraform"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-public-rt"
  }
}
resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = var.public_subnet
  subnet_id = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_eip" "nat-eip" {
  for_each = var.public_subnet
  domain = "vpc"
  tags = {
    Name = "${var.environment}-nat-eip"
    Environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each = var.public_subnet
  allocation_id = aws_eip.nat-eip[each.key].id
  subnet_id = aws_subnet.public_subnet[each.key].id
  tags = {
    Name = "${var.environment}-nat"
    Environment = "${var.environment}"
  }
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private-rt" {
  for_each = var.private_subnet
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-private-rt"
  }
}

resource "aws_route" "private_route" {
  for_each = var.private_subnet
  route_table_id = aws_route_table.private-rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[each.value.nat_gateway_key].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = var.private_subnet
  subnet_id = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private-rt[each.key].id
}

