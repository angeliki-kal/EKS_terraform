# vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "main"
  }
}

# igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

# 4 subnets
resource "aws_subnet" "private-eu-west-3a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "eu-west-3a"

  tags = {
    "Name"                            = "private-eu-west-3a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/test"      = "owned"
  }
}

resource "aws_subnet" "private-eu-west-3b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "eu-west-3b"

  tags = {
    "Name"                            = "private-eu-west-3b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/test"      = "owned"
  }
}
resource "aws_subnet" "public-eu-west-3a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                   = "public-eu-west-3a"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/" = "owned"
  }
}

resource "aws_subnet" "public-eu-west-3b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "public-eu-west-3b"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/test" = "owned"
  }
}

#nat
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-eu-west-3a.id

  tags = {
    Name = "nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

# routes
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "private-eu-west-3a" {
  subnet_id      = aws_subnet.private-eu-west-3a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-eu-west-3b" {
  subnet_id      = aws_subnet.private-eu-west-3b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-eu-west-3a" {
  subnet_id      = aws_subnet.public-eu-west-3a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-eu-west-3b" {
  subnet_id      = aws_subnet.public-eu-west-3b.id
  route_table_id = aws_route_table.public.id
}
