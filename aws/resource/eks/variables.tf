variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "tomoki-eks-verification-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired node count for the managed node group"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum node count"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum node count"
  type        = number
  default     = 1
}

variable "instance_types" {
  description = "EC2 instance types for the node group"
  type        = list(string)
  default     = ["m5.large"]
  #default     = ["m5.xlarge"]
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "disk_size" {
  description = "Size of the disk attached to each node in GB"
  type        = number
  default     = 150
}


