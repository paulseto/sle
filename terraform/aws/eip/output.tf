output "hostname_to_ip" {
  value = { for host, eip in data.aws_eip.this : host => eip.public_ip }
}
output "hostname_to_allocation_id" {
  value = { for host, eip in data.aws_eip.this : host => eip.id }
}
