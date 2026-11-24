output "automation_engine_ip" {
  value = module.automation_engine.public_ip
}

output "sip_edge_ip" {
  value = module.sip_edge.public_ip
}

output "nat_egress_ip" {
  value = module.network.nat_egress_ip
}

output "media_ingest_url" {
  value = module.media.ingest_url
}
