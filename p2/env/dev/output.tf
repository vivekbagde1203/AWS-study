output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}
output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}
output "eks_role_arn" {
  value = module.iam.eks_role_arn
}
output "eks_cluster_id" {
  value = module.eks.eks_cluster_id
}
