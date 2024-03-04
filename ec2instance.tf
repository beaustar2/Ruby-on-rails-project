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

    # Install Docker
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    
    # Add ec2-user to the docker group to run Docker commands without sudo
    sudo usermod -aG docker ec2-user

    # Verify Docker installation
    docker --version

    # Start the Docker service
    sudo systemctl start docker

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Check Docker Compose version
    docker-compose --version

    # Install Ruby and other dependencies
    sudo yum update -y
    sudo yum install git -y
    sudo yum -y install ruby
    sudo yum -y groupinstall "Development Tools"
    sudo gem install bundler
    gem update --system
    sudo yum -y install ruby-devel
    gem install rails -v 6.1.4

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Clone the Git repository and navigate to the project directory
    git clone https://github.com/beaustar2/Ruby-on-rails-project.git /home/ec2-user/Ruby-on-rails-project
    cd /home/ec2-user/Ruby-on-rails-project

    # Run docker run command to create a new Rails app
    rails new rails-docker --apl --database=postgresql

    cd /home/ec2-user/Ruby-on-rails-project/rails-docker

    # Remove files
    sudo rm -rf Dockerfile Gemfile \
        /home/ec2-user/Ruby-on-rails-project/rails-docker/config/database.yaml \
        /home/ec2-user/Ruby-on-rails-project/rails-docker/config/routes.rb \
        /home/ec2-user/Ruby-on-rails-project/rails-docker/bin/docker-entrypoint

    # Move files
    mv /home/ec2-user/Ruby-on-rails-project/Dockerfile \
        /home/ec2-user/Ruby-on-rails-project/env \
        /home/ec2-user/Ruby-on-rails-project/ruby.version \
        /home/ec2-user/Ruby-on-rails-project/docker-entrypoint \
        /home/ec2-user/Ruby-on-rails-project/database.yaml \
        /home/ec2-user/Ruby-on-rails-project/routes.rb \
        /home/ec2-user/Ruby-on-rails-project/Gemfile \
        /home/ec2-user/Ruby-on-rails-project/Gemfile.lock \
        /home/ec2-user/Ruby-on-rails-project/docker-compose.yaml \
        /home/ec2-user/Ruby-on-rails-project/dockerfile.postgres \
        .

    # Move and rename files
    mv /home/ec2-user/rails-docker/Ruby-on-rails-project/docker-entrypoint \
        /home/ec2-user/Ruby-on-rails-project/rails-docker/bin

    mv /home/ec2-user/rails-docker/Ruby-on-rails-project/database.yaml \
        /home/ec2-user/Ruby-on-rails-project/rails-docker/config

    mv /home/ec2-user/rails-docker/Ruby-on-rails-project/routes.rb \
        /home/ec2-user/Ruby-on-rails-project/rails-docker/config


    # Print the master.key
    echo "RAILS_MASTER_KEY=$MASTER_KEY"

    # Save the master.key to a .env file
    echo "RAILS_MASTER_KEY=$MASTER_KEY" > .env

    # Generate the scaffold for the "Post" model
    rails g scaffold post title body:text

    # Build and run the containers
    docker-compose build && docker-compose up
  EOF
}