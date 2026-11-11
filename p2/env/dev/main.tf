module "vpc" {
  source         = "../../modules/vpc"
  environment    = var.environment
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
  vpc_cidr       = var.vpc_cidr
}
module "eks" {
  source             = "../../modules/eks"
  vpc_id             = module.vpc.vpc_id
  private_subnet_id  = module.vpc.private_subnet_id
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  eks_role_arn       = module.iam.eks_role_arn
}
module "iam" {
  source       = "../../modules/iam"
  cluster_name = var.cluster_name
}
