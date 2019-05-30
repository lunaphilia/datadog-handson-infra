/**
 * ## Inputs
 *
 * | Name | Description | Type | Default | Required |
 * |------|-------------|:----:|:-----:|:-----:|
 * | name | アプリケーションに使用する命名。 | string | `"myapp"` | no |
 * | tags | 各リソースに付与するtag | map | `<map>` | no |
 *
 * ## Outputs
 *
 * | Name | Description |
 * |------|-------------|
 * | id | クラスターARN |
 * | name | クラスター名 |
 */

#########################
# ECS Cluster
#########################
resource "aws_ecs_cluster" "this" {
  name = "${var.name}"
  tags = "${var.tags}"
}
