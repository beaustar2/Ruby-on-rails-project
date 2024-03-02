# Resource-10: Create Security Group
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

  # Allow outbound traffic to any destination
  egress {
    description = "Allow all IP and Ports Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Ruby-SG"
  }
}