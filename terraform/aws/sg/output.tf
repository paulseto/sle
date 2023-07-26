output "nfs_sg_id" {
  value = var.create_efs ? module.nfs.security_group_id : null
}
output "http_sg_id" {
  value = module.http.security_group_id
}
output "https_sg_id" {
  value = module.https.security_group_id
}
# output "sip_sg_id" {
#   value = module.sip.security_group_id
# }
output "ssh_sg_id" {
  value = module.ssh.security_group_id
}
output "turn_sg_id" {
  value = module.turn.security_group_id
}
output "webrtc_sg_id" {
  value = module.webrtc.security_group_id
}
output "cache_sg_id" {
  value = var.create_cache ? module.cache.security_group_id : null
}
output "db_sg_id" {
  value = var.create_db ? module.db.security_group_id : null
}

output "bbb_sg_id" {
  value = module.bbb.security_group_id
}
