output "vpc-data" {
  value = module.vpc-data
}
output "eip" {
  value = module.eip
}
output "efs" {
  value = module.efs
}
output "sg" {
  value = module.sg
}
output "cache" {
  value = module.cache
}
output "rds" {
  value     = module.rds
  sensitive = true
}
output "bbb" {
  value = module.bbb
}
output "sl" {
  value     = module.sl
  sensitive = true
}
output "gl" {
  value = module.gl
}
