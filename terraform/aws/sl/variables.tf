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
variable "efs_dns" {
  type = string
}
variable "cache_dns" {
  type = string
}
variable "db_dns" {
  type = string
}
variable "db_name" {
  type = string
}
variable "master_username" {
  type = string
}
variable "master_password" {
  type = string
}
variable "port" {
  type = number
}
variable "lb_secret" {
  type = string
}
variable "db_use_docker" {
  type = bool
}
variable "db_docker_image" {
  type = string
}
variable "cache_use_docker" {
  type = bool
}
variable "cache_docker_image" {
  type = string
}
variable "sl_image_tag" {
  type = string
}
variable "ssl_crt_file" {
  type = string
}
variable "ssl_key_file" {
  type = string
}
variable "enable_tenants" {
  type = bool
}
variable "tenants" {
  type = map(any)
}
variable "tenant_crt_file" {
  type = string
}
variable "tenant_key_file" {
  type = string
}
