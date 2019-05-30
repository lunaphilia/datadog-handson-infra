/**
 * # Usage
 * ```ruby
 * module "vpc" {
 *   source = "git::https://git.dmm.com/sre-terraform/tf-vpc.git?ref=v1.0.0"
 * }
 *
 * module "bastion_sg" {
 *   source = "git::https://git.dmm.com/sre-terraform/tf-security-group.git?ref=v1.0.0"
 *
 *   vpc_id = "${module.vpc.vpc_id}"
 *
 *   name        = "bastion"
 *   description = "bastion"
 *
 *   ingress_with_cidr_block_rules = [
 *     {
 *       cidr_blocks = "0.0.0.0/0"
 *       from_port   = 22
 *       to_port     = 22
 *       protocol    = "tcp"
 *       description = "Allow all IP at 22 port"
 *     },
 *   ]
 * }
 *
 * data "aws_ssm_parameter" "public_key" {
 *   name = "/${var.name}/bastion/ssh/public"
 * }
 *
 * module "bastion" {
 *   source = "git::https://git.dmm.com/sre-terraform/tf-bastion.git?ref=v1.0.0"
 *
 *   subnets         = "${module.vpc.public_subnets}"
 *   security_groups = ["${module.bastion_sg.sg_id}"]
 *
 *   public_key = "${data.aws_ssm_parameter.public_key.value}"
 * }
 * ```
 */

#########################
# Key Pair
#########################
resource "aws_key_pair" "this" {
  public_key = "${var.public_key}"
  key_name   = "${var.name}-bastion"
}

#########################
# EC2
#########################
data "aws_ssm_parameter" "latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "this" {
  ami = "${data.aws_ssm_parameter.latest_ami.value}"

  subnet_id              = "${var.subnets[0]}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${var.security_groups}"]
  key_name               = "${aws_key_pair.this.key_name}"

  associate_public_ip_address = "${var.associate_public_ip_address}"
  monitoring                  = true

  tags = "${merge(map("Name", format("%s-bastion", var.name)), var.tags)}"
}

resource "aws_eip" "this" {
  vpc = true

  instance = "${aws_instance.this.id}"
  tags     = "${merge(map("Name", format("%s-bastion", var.name)), var.tags)}"
}
