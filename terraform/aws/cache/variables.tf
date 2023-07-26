variable "create" {
  type = bool
}
variable "instance_type" {
  type = string
}
variable "instance_count" {
  type = number
}
variable "engine" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "prefix" {
  type = string
}
variable "tags" {
  type = map(any)
}
variable "parameter_group" {
  type = string
}
variable "availability_zones" {
  type = list(string)
}
variable "security_group_ids" {
  type = list(string)
}
variable "subnet_ids" {
  type = list(string)
}
