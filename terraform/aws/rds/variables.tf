variable "create" {
  type = bool
}
variable "prefix" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "tags" {
  type = map(any)
}
variable "engine" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "parameter_group" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "instance_count" {
  type = number
}
variable "availability_zones" {
  type = list(string)
}
variable "root_username" {
  type = string
}
variable "root_password" {
  type = string
}
