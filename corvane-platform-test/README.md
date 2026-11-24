# Corvane infrastructure

Corvane provides AI voice agents and video analytics to security monitoring centres. When an alarm fires at a client site, our platform receives the event, pulls the camera clips, scores them, and calls the right people. Clients connect to us over the internet or over a site-to-site VPN.

Everything runs in GCP, managed with Terraform.

## Clients

| Client | Connection | Status |
|---|---|---|
| Northgate | Site-to-site VPN | Live since March 2025. A second site (`10.40.1.0/24`) is being added. |
| Westmere | Site-to-site VPN | Live since 14 September 2026. |
| Hollins | Internet | Onboarded 20 October 2026. Nightly sync running. |

## Layout

```
environments/
  prod/        project corvane-prod, state in gs://corvane-prod-tfstate
  dev/         project corvane-dev,  state in gs://corvane-dev-tfstate
modules/
  network/            VPC, subnet, firewall rules, Cloud NAT with a reserved egress IP
  automation_engine/  self-hosted workflow engine VM; receives client and carrier webhooks
  sip_edge/           SIP border VMs between telephony carriers and the voice agents
  core_db/            Cloud SQL Postgres
  media/              clip archive bucket, media-ingest service, frame-analysis job
  client_vpn/         IPsec tunnel to one client site
  client_sync/        scheduled import of one client's sites and contacts
state/
  prod.tfstate        latest production state
```

Secrets (`db_app_password`, `vpn_shared_secrets`) are supplied by CI from Secret Manager.
