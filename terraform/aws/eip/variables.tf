variable "create" {
  type = bool
}
variable "hostnames" {
  type = list(string)
}
variable "domain" {
  type = string
}
variable "default_tags" {
  type = map(any)
}
