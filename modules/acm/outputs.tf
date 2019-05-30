output "acm_arn" {
  description = "作成されたACMのARN"
  value       = "${aws_acm_certificate.cert.arn}"
}
