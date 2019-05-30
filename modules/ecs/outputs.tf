output "id" {
  description = "クラスターARN"
  value       = "${aws_ecs_cluster.this.id}"
}

output "name" {
  description = "クラスター名"
  value       = "${aws_ecs_cluster.this.name}"
}
