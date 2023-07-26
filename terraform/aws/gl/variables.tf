variable "instance_count" {
  type = number
}
variable "instance_size" {
  type = number
}
variable "instance_type" {
  type = string
}
variable "hostname_pattern" {
  type = string
}
variable "hostname" {
  type = string
}
variable "iam_role" {
  type = string
}
variable "ami_id" {
  type = string
}
variable "ami_name_filter" {
  type = string
}
variable "domain" {
  type = string
}
variable "key_name" {
  type = string
}
variable "ssh_user" {
  type = string
}
variable "key_file" {
  type = string
}
variable "default_tags" {
  type = map(any)
}
variable "security_groups" {
  type = list(string)
}
variable "subnets" {
  type = list(string)
}
variable "hostname_to_ip" {
  type = map(any)
}
variable "hostname_to_allocation_id" {
  type = map(any)
}
variable "ssl_key_file" {
  type = string
}
variable "ssl_crt_file" {
  type = string
}
variable "sl_hostname" {
  type = string
}
variable "sl_secret" {
  type = string
}
variable "admin_email" {
  type = string
}
variable "admin_password" {
  type = string
}
variable "admin_name" {
  type = string
}
