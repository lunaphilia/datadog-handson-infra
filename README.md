# インフラストラクチャリポジトリ

## 環境の構築
scripts/create.shを実行

## 環境の変更

通常のterraformの修正と同様

terraform initが必要になった際は以下を実施

```
AWS_ACCOUNTID="$(aws sts get-caller-identity --query Account --output text)"
BACKEND_BUCKET="terraform-backend-$AWS_ACCOUNTID"
terraform init -backend-config="bucket=$BACKEND_BUCKET"
```

## 環境の削除
scripts/destroy.shを実行
