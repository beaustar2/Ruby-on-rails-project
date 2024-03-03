# Resource-1: Create VPC
resource "aws_vpc" "ruby-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    "Name" = "ruby vpc"
  }
}

# Resource-4: Create Internet Gateway
resource "aws_internet_gateway" "ruby-igw" {
  vpc_id = aws_vpc.ruby-vpc.id
  tags = {
    Name = "ruby igw"
  }
}

# Resource-5: Attach IGW to the VPC
resource "aws_internet_gateway_attachment" "ruby-igw-attachment" {
  vpc_id              = aws_vpc.ruby-vpc.id
  internet_gateway_id = aws_internet_gateway.ruby-igw.id
}

# Resource-2: Create Public Subnet with IGW
resource "aws_subnet" "ruby-public-subnet" {
  vpc_id                  = aws_vpc.ruby-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ruby public subnet1"
  }
}

# Resource-3: Create Private Subnet with NAT Gateway
resource "aws_subnet" "ruby-private-subnet" {
  vpc_id                  = aws_vpc.ruby-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false
  tags = {
    Name = "ruby private subnet1"
  }
}

# Resource-6: Create NAT Gateway in the Public Subnet
resource "aws_nat_gateway" "ruby-nat-gateway" {
  allocation_id = aws_internet_gateway.ruby-igw.id
  subnet_id     = aws_subnet.ruby-public-subnet.id
}

# Resource-7: Create Route Table for Public Subnet
resource "aws_route_table" "ruby-public-route-table" {
  vpc_id = aws_vpc.ruby-vpc.id
  tags = {
    Name = "ruby public route table"
  }
}

# Resource-8: Create Route Table for Private Subnet
resource "aws_route_table" "ruby-private-route-table" {
  vpc_id = aws_vpc.ruby-vpc.id
  tags = {
    Name = "ruby private route table"
  }
}

# Resource-9: Create Route in Public Route Table for Internet Access
resource "aws_route" "ruby-public-route" {
  route_table_id         = aws_route_table.ruby-public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ruby-igw.id
}

# Resource-10: Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "ruby-public-route-table-associate" {
  route_table_id = aws_route_table.ruby-public-route-table.id
  subnet_id      = aws_subnet.ruby-public-subnet.id
}

# Resource-11: Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "ruby-private-route-table-associate" {
  route_table_id = aws_route_table.ruby-private-route-table.id
  subnet_id      = aws_subnet.ruby-private-subnet.id
}

# Resource-13: Create Route in Private Route Table for NAT Gateway
resource "aws_route" "ruby-private-nat-route" {
  route_table_id         = aws_route_table.ruby-private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.pub-nat.id # Use NAT Gateway
}

# Resource-14: Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "ruby-eip_NAT"
  }
}

# Resource-15: Create NAT Gateway
resource "aws_nat_gateway" "pub-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.ruby-public-subnet.id
  tags = {
    Name = "ruby-gw NAT"
  }
}

# Resource-12: Create Security Group
resource "aws_security_group" "ruby-sg" {
  name        = "Ruby,SSH & PostgreSQL"
  description = "Allow Ruby,SSH and PostgreSQL traffic"
  vpc_id      = aws_vpc.ruby-vpc.id

  # Allow SSH from port 22 
  ingress {
    description = "Allow SSH from port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Ruby on Rails traffic 
  ingress {
    description = "Allow Ruby on Rails traffic"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow PostgreSQL traffic 
  ingress {
    description = "Allow PostgreSQL traffic"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Ruby-SG"
  }
}