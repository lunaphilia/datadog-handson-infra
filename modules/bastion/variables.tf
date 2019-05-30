variable "name" {
  description = "アプリケーションに使用する命名。"
  default     = "myapp"
}

variable "tags" {
  description = "各リソースに付与するtag"
  default     = {}
}

variable "subnets" {
  description = "EC2を配置するサブネット一覧 e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = "list"
}

variable "security_groups" {
  description = "EC2に登録するセキュリティグループ一覧 e.g. ['sg-edcd9784','sg-edcd9785']"
  type        = "list"
}

variable "public_key" {
  description = "EC2ログイン用の公開鍵"
  type        = "string"
}

variable "instance_type" {
  description = "使用するEC2のタイプ"
  default     = "t3.micro"
}

variable "associate_public_ip_address" {
  description = "踏み台にPublicIPを付与する"
  default     = true
}
