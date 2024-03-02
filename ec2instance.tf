resource "aws_instance" "Ruby-on-rail" {
  ami                    = "ami-05a36e1502605b4aa"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ruby-public-subnet.id
  key_name               = "kiki"
  vpc_security_group_ids = [aws_security_group.ruby-sg.id]
  private_ip             = "10.0.1.20"
  tags = {
    Name = "Ruby-on-rail"
  }

  user_data = <<-EOF
    #!/bin/bash

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

    # Install Ruby and RubyGems
    sudo yum -y install  ruby ruby-devel

    # Install Bundler
    sudo gem install bundler

    # Clone the Git repository and navigate to project directory
    git clone https://github.com/beaustar2/Ruby-on-rails-project.git /home/centos/Ruby-on-rails-project
    cd /home/centos/Ruby-on-rails-project

    # Run docker run command to create a new Rails app
    sudo docker run --rm -v $(pwd):/app ruby:3.2.0 rails new . --force --database=postgresql

    # Update database.yml
    cat > config/database.yml <<EOL
    default: &default
      adapter: postgresql
      encoding: unicode
      pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
      username: postgres
      password: <%= ENV['POSTGRES_PASSWORD'] %>
      host: db

    development:
      <<: *default
      database: myapp_development

    test:
      <<: *default
      database: myapp_test

    production:
      <<: *default
      database: myapp_production
    EOL

    # Build and run the containers
    docker-compose up --build
  EOF
}