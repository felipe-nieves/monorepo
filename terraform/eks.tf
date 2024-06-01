# Cluster

resource "aws_eks_cluster" "primary" {
  name     = "primary"
  role_arn = aws_iam_role.cluster_eks_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.eks-1a.id, aws_subnet.eks-1b.id, aws_subnet.eks-1c.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_vpc.eks,
    aws_subnet.eks-1a,
    aws_subnet.eks-1b,
    aws_subnet.eks-1c
  ]
}

output "endpoint" {
  value = aws_eks_cluster.primary.endpoint
}

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.primary.certificate_authority[0].data
# }

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Cluster Role

resource "aws_iam_role" "cluster_eks_role" {
  name               = "eks-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_eks_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster_eks_role.name
}

# Node Group

resource "aws_eks_node_group" "primary" {
  cluster_name    = aws_eks_cluster.primary.name
  node_group_name = "primary"
  node_role_arn   = aws_iam_role.cluster_eks_role.arn
  subnet_ids      = aws_subnet.eks-1[*].id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = "t4g.nano"

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_eks_cluster.primary,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Node Group Role

resource "aws_iam_role" "eks_primary_node_group_role" {
  name = "eks-primary-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_primary_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_primary_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_primary_node_group_role.name
}