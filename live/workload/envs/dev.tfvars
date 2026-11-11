environment = "dev"
account_id  = "222222222222" # replace with the workload-dev account ID
vpc_cidr    = "10.10.0.0/16"

# One NAT gateway is enough outside production and saves two gateways' cost.
single_nat_gateway = true

github_repositories = ["example-org/platform"]
