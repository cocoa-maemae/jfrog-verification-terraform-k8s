output "subnet_id_for_verification" {
  value = aws_subnet.verification.id
}

output "security_group_id_for_verification" {
  value = aws_security_group.verification.id
}

output "subnet_ids" {
  description = "List of subnet IDs for EKS cluster"
  value = [
    aws_subnet.eks_public_1.id,
    aws_subnet.eks_public_2.id,
    aws_subnet.eks_private_1.id,
    aws_subnet.eks_private_2.id
  ]
}