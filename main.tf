provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

module "vpc" {
  source = "./modules/vpc"

  name = "${local.name}"
  tags = "${local.tags}"
  cidr = "${local.workspace["cidr"]}"

  public_subnets = [
    "${cidrsubnet(local.workspace["cidr"], 3, 0)}",
    "${cidrsubnet(local.workspace["cidr"], 3, 1)}",
    "${cidrsubnet(local.workspace["cidr"], 3, 2)}",
  ]

  private_subnets = [
    "${cidrsubnet(local.workspace["cidr"], 3, 4)}",
    "${cidrsubnet(local.workspace["cidr"], 3, 5)}",
    "${cidrsubnet(local.workspace["cidr"], 3, 6)}",
  ]

  single_nat_gateway     = "${local.workspace["vpc_single_nat_gateway"]}"
  one_nat_gateway_per_az = "${local.workspace["vpc_one_nat_gateway_per_az"]}"
}

module "alb_sg" {
  source = "./modules/security_group"

  vpc_id      = "${module.vpc.vpc_id}"
  name        = "${local.name}-alb"
  description = "basic alb rule"

  ingress_with_cidr_block_rules = [
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow all IP at 80 port"
    },
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow all IP at 443 port"
    },
  ]
}

/* SSL
module "acm" {
  source = "./modules/acm"

  name    = "${local.name}"
  domains = ["${local.workspace["web_domain_name"]}"]
}

data "aws_route53_zone" "primary" {
  name = "${local.workspace["domain_hosted_zone"]}"
}

resource "aws_route53_record" "web" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${local.workspace["web_domain_name"]}"
  type    = "A"

  alias {
    name                   = "${module.alb.alb_dns_name}"
    zone_id                = "${module.alb.alb_zone_id}"
    evaluate_target_health = false
  }
}

module "alb" {
  source = "./modules/alb"

  name                 = "${local.name}"
  tags                 = "${local.tags}"
  subnets              = "${module.vpc.public_subnets}"
  security_groups      = ["${module.alb_sg.sg_id}"]
  // https_listener_count = 1
  // acm_arn              = "${module.acm.acm_arn}"
}
*/

module "alb" {
  source = "./modules/alb"

  name                 = "${local.name}"
  tags                 = "${local.tags}"
  subnets              = "${module.vpc.public_subnets}"
  security_groups      = ["${module.alb_sg.sg_id}"]
}

module "ecs" {
  source = "./modules/ecs"

  name = "${local.name}"
  tags = "${local.tags}"
}

/* Bastion
module "bastion_sg" {
  source = "./modules/security_group"

  vpc_id = "${module.vpc.vpc_id}"

  name        = "bastion"
  description = "bastion"

  ingress_with_cidr_block_rules = [
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow all IP at 22 port"
    },
  ]

  number_of_computed_ingress_with_source_security_group_rules = 1

  ingress_with_security_group_rules = [
    {
      source_security_group_id = "${module.bastion_sg.sg_id}"
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow from bastion at 22 port"
    },
  ]
}

data "aws_ssm_parameter" "public_key" {
  name = "/${local.name}/bastion/ssh/public"
}

module "bastion" {
  source = "./modules/bastion"

  subnets         = "${module.vpc.public_subnets}"
  security_groups = ["${module.bastion_sg.sg_id}"]

  public_key = "${data.aws_ssm_parameter.public_key.value}"
}
*/

module "mysql_sg" {
  source = "./modules/security_group"

  vpc_id = "${module.vpc.vpc_id}"

  name        = "${local.name}-mysql"
  description = "${local.name} mysql"

  ingress_with_cidr_block_rules = [
    {
      cidr_blocks = "${local.workspace["cidr"]}"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow access within VPC at 3306 port"
    },
  ]
}

data "aws_ssm_parameter" "database_name" {
  name = "/${local.name}/db/database_name"
}

data "aws_ssm_parameter" "master_username" {
  name = "/${local.name}/db/master_username"
}

data "aws_ssm_parameter" "master_password" {
  name = "/${local.name}/db/master_password"
}

module "mysql" {
  source = "./modules/aurora"

  name = "${local.name}"

  subnets            = "${module.vpc.private_subnets}"
  security_group_ids = ["${module.mysql_sg.sg_id}"]

  # DB接続情報
  database_name   = "${data.aws_ssm_parameter.database_name.value}"
  master_username = "${data.aws_ssm_parameter.master_username.value}"
  master_password = "${data.aws_ssm_parameter.master_password.value}"

  # インスタンスクラス
  instance_class = "${local.workspace["mysql_instance_class"]}"

  # 削除保護
  deletion_protection = "${local.workspace["mysql_deletion_protection"]}"

  # オートスケールの最小・最大
  replica_scale_min = "${local.workspace["mysql_replica_scale_min"]}"
  replica_scale_max = "${local.workspace["mysql_replica_scale_max"]}"
}

resource "aws_ssm_parameter" "foo" {
  name  = "/${local.name}/db/database_endpoint"
  type  = "String"
  value = "${module.mysql.endpoint}"
}