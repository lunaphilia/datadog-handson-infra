output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}

output "ecs_cluster_name" {
  value = "${module.ecs.name}"
}

output "http_listener_arn" {
  value = "${module.alb.http_listener_arn}"
}
