# At first- add new ssh key in aws called 'key1' so it could be used with new ec2 instances
# Fix route table internet gateway 

resource "aws_route" "update_internet_gateway_route" {
  route_table_id         = "rtb-0ff736236411a9916" 
  destination_cidr_block = "0.0.0.0/0"             
  gateway_id             = "igw-0e5b2e8a317ac84e2"          
}

# Fix security group inbound rule
resource "aws_security_group_rule" "allow_http_and_custom_ports" {
  security_group_id = "sg-08eb59cf2f1dcb86f"
  type              = "ingress"
  from_port         = 80
  to_port           = 82
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]           
}

#Create subnet for new instance
resource "aws_subnet" "recruitment_candidate013_02" {
  vpc_id            = "vpc-0d51a0a757f221020"  
  cidr_block        = "172.16.1.0/24"    
  availability_zone = "eu-west-1a"        
  map_public_ip_on_launch = true           
  tags = {
    Name = "recruitment_candidate013_02"
  }
}

#Associate new subnet with existing routing table
resource "aws_route_table_association" "recruitment_candidate013_02" {
  subnet_id      = aws_subnet.recruitment_candidate013_02.id
  route_table_id = "rtb-0ff736236411a9916"  
}

#Create new instance 
resource "aws_instance" "recngx02" {
  ami                         = "ami-004c79978ca489451"  
  instance_type               = "t3.micro"           
  subnet_id                   = "subnet-0ddb08fb3793be7f5" 
  key_name                    = "key1"               
  associate_public_ip_address = true                  
  iam_instance_profile        = "recruitment@candidate013" 
  
  security_groups             = ["sg-08eb59cf2f1dcb86f"]

  root_block_device {
    volume_type           = "gp2"                         
    delete_on_termination = true
  }

  user_data = <<-EOF
              #cloud-config

              write_files:
                - path: /tmp/docker-compose.yml
                  owner: root:root
                  permissions: '0644'
                  encoding: b64
                  content: dmVyc2lvbjogJzMnCgpzZXJ2aWNlczoKICB3ZzoKICAgIGltYWdlOiB0aXZpeC9kb2NrZXItbmdpbng6djExCiAgICBjb250YWluZXJfbmFtZTogcHJveHkKICAgIHBvcnRzOgogICAgICAtIDgwOjgwCiAgICBsb2dnaW5nOgogICAgICBkcml2ZXI6IGpzb24tZmlsZQogICAgICBvcHRpb25zOgogICAgICAgIG1heC1zaXplOiA1MG0KICAgIGVudmlyb25tZW50OgogICAgICAtIE1BSU5URU5BTkNFPXRydWUK

              apt:
                sources:
                  docker.list:
                    source: deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable
                    keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

              packages:
                - docker-ce
                - docker-ce-cli
                - containerd.io
                - docker-compose

              runcmd:
                - cd /tmp && docker-compose up -d
              EOF
}





 
