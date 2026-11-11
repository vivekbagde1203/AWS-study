variable "environment" {}
variable "vpc_cidr" {
  type = string
  description = "cidr range of vpc"
}
variable "public_subnet" {
  type = map(object({
    cidr_block = string
    availability_zone = string
    nat_gateway_key = string
  }))
}
variable "private_subnet" {
  type = map(object({
    cidr_block = string
    availability_zone = string
    nat_gateway_key = string
  }))
}


