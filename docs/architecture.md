# Architecture notes

## Accounts

| Account | OU | Purpose |
| --- | --- | --- |
| management | (root) | Organization, billing, Identity Center, Terraform state. No workloads. |
| log-archive | security | Destination for organization-wide logs; write-once from other accounts. |
| security-audit | security | Read access into every account for security tooling and reviews. |
| shared-services | infrastructure | CI runners, container registry, shared DNS. |
| workload-dev | workloads | Non-production workloads. |
| workload-prod | workloads | Production workloads. |

Separate accounts are the strongest isolation boundary AWS offers. A mistake
or a compromised credential in dev cannot reach prod data, and each account
gets its own service quotas and bill.

## Access model

| Group | Permission set | Accounts |
| --- | --- | --- |
| platform-engineers | AdministratorAccess (1 hour sessions) | all |
| developers | PowerUser | workload-dev |
| developers | ReadOnly | workload-prod |
| auditors | ReadOnly | all |

Changes to production go through the pipeline, not through a developer's
console session. Developers can still read production to debug.

Pipelines use the `github-deploy` role in each workload account. Its trust
policy accepts only tokens for the `main` branch of the listed repositories.

## Service control policies

`protect-guardrails` is attached to every OU:

- deny `organizations:LeaveOrganization`
- deny stopping or deleting CloudTrail, Config recorders and GuardDuty detectors
- deny all actions by the root user

`region-restriction` is attached to the workloads and sandbox OUs and denies
regional API calls outside the allowed regions. Global services (IAM,
Route 53, CloudFront, STS and others) are excluded with `NotAction`, because
they are served from `us-east-1` regardless of where the workload runs.

SCPs never grant access. They only cap what IAM in the account can allow, and
they do not apply to the management account, which is one more reason to keep
workloads out of it.

## Network

Each workload VPC is a /16 split into /20 subnets:

| Tier | Subnet index | Example (10.10.0.0/16) |
| --- | --- | --- |
| public | 0 to 2 | 10.10.0.0/20, 10.10.16.0/20, 10.10.32.0/20 |
| (reserved) | 3 to 7 | room for a data or intra tier |
| private | 8 to 10 | 10.10.128.0/20, 10.10.144.0/20, 10.10.160.0/20 |

Production uses one NAT gateway per AZ so an AZ failure does not cut egress
for the others. Dev uses a single gateway, which is an accepted risk in
exchange for lower cost.

CIDR ranges do not overlap between environments, so they can be peered or
attached to a transit gateway later.

## State

All state lives in one bucket in the management account, one key per
environment (`<environment>/terraform.tfstate`). The bucket is versioned,
encrypted with a dedicated KMS key and rejects non-TLS requests. Locking uses
S3 lock files (`use_lockfile`, Terraform 1.10+), so there is no DynamoDB table
to create, pay for or keep in sync.

### Bootstrapping

The management configuration creates the bucket that stores its own state, so
the first run is a two-step process:

1. Comment out `backend "s3" {}` in `live/management/versions.tf` and apply
   with local state.
2. Restore the backend block and run
   `terraform -chdir=live/management init -migrate-state -backend-config=backend/management.hcl`.

After that every environment uses the remote backend.

## What is deliberately left out

- **Organization CloudTrail, Config and GuardDuty.** The SCPs protect them and
  the accounts for them exist, but enabling them belongs in a follow-up module
  so their cost is an explicit decision.
- **Transit gateway and shared networking.** Not needed until there is more
  than one VPC that must talk to another.
- **Account vending automation.** Accounts are added by editing a map and
  opening a pull request, which is enough at this size.
