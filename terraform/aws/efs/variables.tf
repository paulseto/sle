variable "default_tags" {
  type = map(any)
}
variable "prefix" {
  type = string
}
variable "create" {
  type = bool
}
variable "subnet_ids" {
  type = list(string)
}
variable "iam_roles" {
  type = list(string)
}
variable "security_groups" {
  type = list(string)
}