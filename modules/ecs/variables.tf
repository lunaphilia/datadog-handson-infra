variable "name" {
  description = "アプリケーションに使用する命名。"
  default     = "myapp"
}

variable "tags" {
  description = "各リソースに付与するtag"
  default     = {}
}
