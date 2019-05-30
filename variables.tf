locals {
  workspaces {
    default = "${local.default}"
  }

  workspace = "${local.workspaces[terraform.workspace]}"
  name      = "sample-${terraform.workspace}"

  tags {
    Terraform   = "true"
    Environment = "${terraform.workspace}"
  }
}

locals {
  default {
    cidr                       = "10.2.0.0/22"
    vpc_single_nat_gateway     = true
    vpc_one_nat_gateway_per_az = true
    // domain_hosted_zone         = ""
    // web_domain_name            = ""
    mysql_instance_class       = "db.t2.small"
    mysql_deletion_protection  = false
    mysql_replica_scale_min    = 1
    mysql_replica_scale_max    = 1
  }
}
