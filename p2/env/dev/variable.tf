variable "public_subnet" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    nat_gateway_key   = string
  }))
}

variable "private_subnet" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    nat_gateway_key   = string
  }))
}

variable "vpc_cidr" {
  type        = string
  description = "vpc cidr"
}
variable "environment" {
  type = string
}



#variable "private_subnet_id" {
#  type = map(string)
#}
variable "cluster_name" {}
variable "kubernetes_version" {}
