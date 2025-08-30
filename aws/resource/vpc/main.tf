/**
 * VPC
 **/
resource "aws_vpc" "verification" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "vpc for verifiation"
  }
}

/**
 * Subnet
 **/
resource "aws_subnet" "verification" {
  vpc_id                  = aws_vpc.verification.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = "true" # assign a public ip automatically

  tags = {
    Name = "subnet for verifiation"
  }
}

# EKS用のパブリックサブネット
resource "aws_subnet" "eks_public_1" {
  vpc_id                  = aws_vpc.verification.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-1a"
    "kubernetes.io/cluster/tomoki-eks-verification-cluster" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

resource "aws_subnet" "eks_public_2" {
  vpc_id                  = aws_vpc.verification.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-1c"
    "kubernetes.io/cluster/tomoki-eks-verification-cluster" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

# EKS用のプライベートサブネット
resource "aws_subnet" "eks_private_1" {
  vpc_id            = aws_vpc.verification.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "eks-private-1a"
    "kubernetes.io/cluster/tomoki-eks-verification-cluster" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

resource "aws_subnet" "eks_private_2" {
  vpc_id            = aws_vpc.verification.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "eks-private-1c"
    "kubernetes.io/cluster/tomoki-eks-verification-cluster" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

/**
 * Internet Gateway
 **/
resource "aws_internet_gateway" "verification" {
  vpc_id = aws_vpc.verification.id

  tags = {
    Name = "verification"
  }
}

/**
 * Route Table
 **/
resource "aws_route_table" "verification" {
  vpc_id = aws_vpc.verification.id

  tags = {
    Name = "verification"
  }
}

resource "aws_route" "verification" {
  gateway_id             = aws_internet_gateway.verification.id
  route_table_id         = aws_route_table.verification.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "verification" {
  subnet_id      = aws_subnet.verification.id
  route_table_id = aws_route_table.verification.id
}

# EKS用のNAT Gateway
resource "aws_eip" "eks_nat" {
  domain = "vpc"
  tags = {
    Name = "eks-nat-eip"
  }
}

resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.eks_nat.id
  subnet_id     = aws_subnet.eks_public_1.id

  tags = {
    Name = "eks-nat-gateway"
  }

  depends_on = [aws_internet_gateway.verification]
}

# EKS用のプライベートサブネット用ルートテーブル
resource "aws_route_table" "eks_private" {
  vpc_id = aws_vpc.verification.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat.id
  }

  tags = {
    Name = "eks-private-route-table"
  }
}

# プライベートサブネットをルートテーブルに関連付け
resource "aws_route_table_association" "eks_private_1" {
  subnet_id      = aws_subnet.eks_private_1.id
  route_table_id = aws_route_table.eks_private.id
}

resource "aws_route_table_association" "eks_private_2" {
  subnet_id      = aws_subnet.eks_private_2.id
  route_table_id = aws_route_table.eks_private.id
}

# パブリックサブネットを既存のルートテーブルに関連付け
resource "aws_route_table_association" "eks_public_1" {
  subnet_id      = aws_subnet.eks_public_1.id
  route_table_id = aws_route_table.verification.id
}

resource "aws_route_table_association" "eks_public_2" {
  subnet_id      = aws_subnet.eks_public_2.id
  route_table_id = aws_route_table.verification.id
}

/**
 * Security Groups
 **/
resource "aws_security_group" "verification" {
  vpc_id = aws_vpc.verification.id
  name   = "security-group-for-verification"

  tags = {
    Name = "security group for verification"
  }
}

resource "aws_security_group_rule" "in_ssh" {
  security_group_id = aws_security_group.verification.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_security_group_rule" "in_http" {
  security_group_id = aws_security_group.verification.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

resource "aws_security_group_rule" "in_https" {
  security_group_id = aws_security_group.verification.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}

resource "aws_security_group_rule" "in_jfrog_af" {
  security_group_id = aws_security_group.verification.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 8082
  to_port           = 8082
  protocol          = "tcp"
}

resource "aws_security_group_rule" "in_jfrog_xray" {
  security_group_id = aws_security_group.verification.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 8081
  to_port           = 8081
  protocol          = "tcp"
}

resource "aws_security_group_rule" "eg_http" {
  security_group_id = aws_security_group.verification.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

resource "aws_security_group_rule" "eg_https" {
  security_group_id = aws_security_group.verification.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}

/*
resource "aws_security_group_rule" "in_icmp" {
  security_group_id = aws_security_group.verification.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
}

resource "aws_security_group_rule" "in_vault" {
  security_group_id = aws_security_group.verification.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 8200
  to_port           = 8200
  protocol          = "tcp"
}
*/