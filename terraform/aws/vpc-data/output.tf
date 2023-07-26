output "vpc_id" {
  value = var.vpc_id
}
output "subnet_ids" {
  value = data.aws_subnets.this.ids
}
output "vpc_cidr_block" {
  value = data.aws_vpc.this.cidr_block
}
output "subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.this : s.cidr_block]
}
output "availability_zones" {
  value = [for s in data.aws_subnet.this : s.availability_zone]
}
output "azs_to_subnets" {
  value = {for s in data.aws_subnet.this : s.availability_zone => s.id}
}