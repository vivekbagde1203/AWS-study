public_subnet = {
  public_a = {
    cidr_block        = "10.0.0.0/19"
    availability_zone = "ap-south-1a"
    nat_gateway_key   = "public_a"
  }
  public_b = {
    cidr_block        = "10.0.32.0/19"
    availability_zone = "ap-south-1b"
    nat_gateway_key   = "public_b"
  }
}

private_subnet = {
  private_a = {
    cidr_block        = "10.0.64.0/19"
    availability_zone = "ap-south-1a"
    nat_gateway_key   = "public_a"
  }
  private_b = {
    cidr_block        = "10.0.96.0/19"
    availability_zone = "ap-south-1b"
    nat_gateway_key   = "public_b"
  }
}

vpc_cidr           = "10.0.0.0/16"
environment        = "dev"
cluster_name       = "ctct-dev-cluster"
kubernetes_version = "1.32.0"
