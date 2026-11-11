variable "vpc_id" {
  type = string
}

variable "private_subnet_id" {
  type = map(string)
}

variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}
variable "eks_role_arn" {
  type = string
}
