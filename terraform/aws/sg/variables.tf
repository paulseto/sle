variable "vpc_id" {
  type = string
}
variable "prefix" {
  type = string
}
variable "default_tags" {
  type = map(any)
}
variable "subnet_cidr_blocks" {
  type = list(string)
}
variable "create_efs" {
  type = bool
}
variable "create_cache" {
  type = bool
}
variable "create_db" {
  type = bool
}
