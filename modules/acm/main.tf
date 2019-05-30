/**
 * tf-acm
 * ---
 *
 * [![CircleCI](https://cci.dmm.com/gh/sre-terraform/tf-acm?style=svg)](https://cci.dmm.com/gh/sre-terraform/tf-acm)
 *
 * # About
 * TLS証明書をAWS Certificate Managerによって取得するためのModule
 *
 * # Components
 * - ACM
 *     - ValidationはDNSによって行う
 *
 * # Usage
 * ## ドメインが1つの場合
 * ```ruby
 * module "acm" {
 *   source = "git::https://git.dmm.com/sre-terraform/tf-acm.git?ref=v1.0.0"
 *
 *   name = "${var.name}"
 *
 *   domains = ["example.com"]
 * }
 * ```
 *
 * ## 復数のHostZoneに1つずつドメインが紐づく場合
 * ```ruby
 * module "acm" {
 *   source = "git::https://git.dmm.com/sre-terraform/tf-acm.git?ref=v1.0.0"
 *
 *   name = "${var.name}"
 *
 *   hostzones = ["www.example.com", "api.example.com"]
 *   domains = ["www.example.com", "api.example.com"]
 * }
 * ```
 *
 * ## 1つのHostZoneに復数のドメインが紐づく場合
 * ```ruby
 * module "acm" {
 *   source = "git::https://git.dmm.com/sre-terraform/tf-acm.git?ref=v1.0.0"
 *
 *   name = "${var.name}"
 *
 *   hostzones = ["example.com"]
 *   domains = ["www.example.com", "api.example.com"]
 * }
 * ```
 *
 * ## 1つのHostZoneに復数のドメインが紐づく場合
 * `hostzones` を設定しない場合 `domains` の0番目が使用される
 * ```ruby
 * module "acm" {
 *   source = "git::https://git.dmm.com/sre-terraform/tf-acm.git?ref=v1.0.0"
 *
 *   name = "${var.name}"
 *
 *   domains = ["example.com", "www.example.com", "api.example.com"]
 * }
 * ```
 */

locals {
  hostzones = "${split(",", length(var.hostzones) > 0 ? join(",", var.hostzones) : var.domains[0] )}"

  domain_name               = "${var.domains[0]}"
  subject_alternative_names = "${slice(var.domains, 1, length(var.domains))}"
}

#########################
# AWS Certificate Manager
#########################
data "aws_route53_zone" "zones" {
  count = "${length(local.hostzones)}"

  name         = "${local.hostzones[count.index]}"
  private_zone = false
}

resource "aws_acm_certificate" "cert" {
  domain_name = "${local.hostzones[count.index]}"

  subject_alternative_names = "${local.subject_alternative_names}"

  validation_method = "DNS"

  tags = "${var.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  depends_on = ["aws_acm_certificate.cert"]

  count = "${length(var.domains)}"

  zone_id = "${length(local.hostzones) > 0 ? element(data.aws_route53_zone.zones.*.id, count.index) : data.aws_route53_zone.zones.0.id }"

  ttl = 60

  name    = "${lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_name")}"
  type    = "${lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_type")}"
  records = ["${lookup(aws_acm_certificate.cert.domain_validation_options[count.index], "resource_record_value")}"]
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = "${aws_acm_certificate.cert.arn}"

  validation_record_fqdns = ["${aws_route53_record.validation.*.fqdn}"]
}
