resource "aws_instance" "Ruby-on-rail" {
  ami                    = "ami-02ca28e7c7b8f8be1"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ruby-public-subnet.id
  key_name               = "kiki"
  vpc_security_group_ids = [aws_security_group.ruby-sg.id]
  private_ip             = "10.0.1.20" # Use the desired IP address here
  tags = {
    Name = "Ruby-on-rail"
  }

  user_data = <<-EOF
    #!/bin/bash

    # Install Ruby
    sudo yum update -y
    sudo yum install git -y
    sudo yum -y install ruby
    sudo yum -y groupinstall "Development Tools"
    sudo gem install bundler
    gem update --system
    sudo yum -y install ruby-devel
    gem install rails

    # Update the system and install git
    sudo yum update -y
    sudo yum install git -y

    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Install Docker using get.docker.com script
    curl -fsSL https://get.docker.com -o install-docker.sh
    sudo sh install-docker.sh
    sudo systemctl start docker

    # Clone the Git repository and navigate to the project directory
    git clone https://github.com/beaustar2/Ruby-on-rails-project.git /home/ec2-user/Ruby-on-rails-project
    cd /home/ec2-user/Ruby-on-rails-project

    # Run docker run command to create a new Rails app
    rails new rails-docker --apl --database=postgresql

    cd /home/ec2-user/Ruby-on-rails-project/rails-docker

    # Print the master.key
    echo "RAILS_MASTER_KEY=$MASTER_KEY"

    # Save the master.key to a .env file
    echo "RAILS_MASTER_KEY=$MASTER_KEY" > .env

    rm -rf Dockerfile Gemfile 
    rm -rf /home/ec2-user/Ruby-on-rails-project/rails-docker/config/database.yaml
    rm -rf /home/ec2-user/Ruby-on-rails-project/rails-docker/config/routes.rb
    rm -rf /home/ec2-user/Ruby-on-rails-project/rails-docker/bin/docker-entrypoint

    mv /home/ec2-user/Ruby-on-rails-project/Dockerfile .
    mv /home/ec2-user/Ruby-on-rails-project/Gemfile .
    mv /home/ec2-user/Ruby-on-rails-project/docker-compose.yaml .
    mv /home/ec2-user/Ruby-on-rails-project/dockerfile.postgres .
    mv /home/ec2-user/rails-docker/Ruby-on-rails-project/docker-entrypoint /home/ec2-user/Ruby-on-rails-project/rails-docker/bin
    mv /home/ec2-user/rails-docker/Ruby-on-rails-project/database.yaml /home/ec2-user/Ruby-on-rails-project/rails-docker/config
    mv /home/ec2-user/rails-docker/Ruby-on-rails-project/routes.rb /home/ec2-user/Ruby-on-rails-project/rails-docker/config

    # Generate the scaffold for the "Post" model
    rails g scaffold post title body:text

    # Build and run the containers
    docker-compose up --build
  EOF
}