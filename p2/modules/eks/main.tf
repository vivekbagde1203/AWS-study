resource "aws_eks_cluster" "main" {
  name = var.cluster_name
  version = var.kubernetes_version
  role_arn = var.eks_role_arn
  vpc_config {
    subnet_ids = values(var.private_subnet_id)
    endpoint_private_access = true
    endpoint_public_access = true
  }
}
