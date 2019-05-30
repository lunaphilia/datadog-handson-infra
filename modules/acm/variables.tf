variable "name" {
  description = "アプリケーションに使用する命名。"
  default     = "myapp"
}

variable "tags" {
  description = "各リソースに付与するtag"
  default     = {}
}

variable "domains" {
  description = "TLS証明書を発行するドメインの一覧"
  type        = "list"
}

variable "hostzones" {
  description = "復数のドメインで検証を行う場合に使用するHostzoneを指定する。指定しない場合はvar.domainsの0番をHostzoneとして使用する"
  default     = []
}
