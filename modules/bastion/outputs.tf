output "id" {
  description = "作成されたEC2のID"
  value       = "${aws_instance.this.id}"
}

output "public_ip" {
  description = "作成されたEC2のPublicIP"
  value       = "${aws_instance.this.public_ip}"
}
