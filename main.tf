#create vpc
resource "aws_vpc" "demo_vpc_local" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name ="my_demo_vpc_remote"
  }
}
#create subnet
resource "aws_subnet" "demo_vpc_local" {
  vpc_id = aws_vpc.demo_vpc_local.id
  cidr_block = "10.0.0.0/24"
}
#create ig and attach to vpc
resource "aws_internet_gateway" "demo_vpc_local" {
  vpc_id = aws_vpc.demo_vpc_local.id
  tags = {
    Name = "my_demo_ig_remote"
  }

}
#create RT and configure ig(edit route)
resource "aws_route_table" "demo_vpc_local" {
  vpc_id = aws_vpc.demo_vpc_local.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_vpc_local.id
  
}
}
#subnet assocaition to add to RT(PUBLIC)
resource "aws_route_table_association" "demo_vpc_local" {
  subnet_id      = aws_subnet.demo_vpc_local.id
  route_table_id = aws_route_table.demo_vpc_local.id
}
#create ec2 server
resource "aws_instance" "demo_vpc_local" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = var.keyname
    vpc_security_group_ids = [ aws_security_group.demo_vpc_local.id ]
    subnet_id = aws_subnet.demo_vpc_local.id
  
}
#security groups
resource "aws_security_group" "demo_vpc_local" {
  name        = "allow_tls"
  vpc_id      = aws_vpc.demo_vpc_local.id
  tags = {
    Name = "dev_sg"
  }
 ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  
}