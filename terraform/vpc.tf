resource "aws_vpc" "eks" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "eks"
  }
}

resource "aws_subnet" "eks-1a" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "eks-1a"
  }
}

resource "aws_subnet" "eks-1b" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "eks-1b"
  }
}

resource "aws_subnet" "eks-1c" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "eks-1c"
  }
}