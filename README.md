# JFrog Platform on Kubernetes

このディレクトリには、KubernetesクラスタにJFrog Platformをインストールするためのマニフェストファイルとスクリプトが含まれています。

## 🚀 概要

JFrog Platformは以下のコンポーネントで構成されています：

- **JFrog Artifactory**: アーティファクト管理リポジトリ
- **JFrog Xray**: セキュリティスキャンとライセンス管理
- **PostgreSQL**: Xray用のデータベース

## 📁 ファイル構成

```
k8s/
├── namespace.yaml                    # ネームスペース定義
├── storage-class.yaml               # ストレージクラス定義
├── artifactory-pvc.yaml            # Artifactory用PVC
├── xray-pvc.yaml                   # Xray用PVC
├── artifactory-config.yaml         # Artifactory設定
├── artifactory-deployment.yaml     # Artifactoryデプロイメント
├── xray-deployment.yaml            # Xrayデプロイメント
├── postgres-deployment.yaml        # PostgreSQLデプロイメント
├── services.yaml                    # サービスとイングレス
├── install-jfrog.sh                # インストールスクリプト
├── uninstall-jfrog.sh              # アンインストールスクリプト
└── README.md                        # このファイル
```

## 🔧 前提条件

- Kubernetes 1.20以上
- kubectlがインストール済み
- AWS EKSクラスタが稼働中
- AWS Load Balancer Controllerがインストール済み
- EBS CSI Driverがインストール済み

## 📦 インストール手順

### 1. スクリプトに実行権限を付与

```bash
chmod +x install-jfrog.sh
chmod +x uninstall-jfrog.sh
```

### 2. JFrog Platformをインストール

```bash
./install-jfrog.sh
```

### 3. インストール状況を確認

```bash
kubectl get pods -n jfrog-platform
kubectl get services -n jfrog-platform
kubectl get pvc -n jfrog-platform
```

## 🌐 アクセス方法

インストール完了後、以下のURLでアクセスできます：

- **JFrog Artifactory**: http://artifactory.local:8082
- **JFrog Xray**: http://xray.local:8080

### ローカル環境でのアクセス

`/etc/hosts`ファイルに以下を追加してください：

```
<CLUSTER_IP> artifactory.local
<CLUSTER_IP> xray.local
```

## 🔐 デフォルト認証情報

- **ユーザー名**: admin
- **パスワード**: password

⚠️ **注意**: 本番環境では必ずパスワードを変更してください。

## 💾 ストレージ設定

### ストレージクラス

- **jfrog-storage**: 汎用SSD (gp3) - 通常のデータ用
- **jfrog-fast-storage**: 高パフォーマンスSSD (io2) - インデックス用

### 永続ボリューム

- **Artifactory**: 100GB (データ) + 20GB (ログ) + 50GB (バックアップ)
- **Xray**: 50GB (データ) + 10GB (ログ) + 30GB (インデックス)
- **PostgreSQL**: 20GB

## 🗑️ アンインストール

```bash
./uninstall-jfrog.sh
```

## 🔧 カスタマイズ

### リソース制限の変更

各Deploymentファイルの`resources`セクションを編集してください：

```yaml
resources:
  requests:
    memory: "2Gi"
    cpu: "1000m"
  limits:
    memory: "4Gi"
    cpu: "2000m"
```

### ストレージサイズの変更

各PVCファイルの`storage`値を編集してください：

```yaml
resources:
  requests:
    storage: 100Gi
```

### レプリカ数の変更

各Deploymentファイルの`replicas`値を編集してください：

```yaml
spec:
  replicas: 3
```

## 🚨 トラブルシューティング

### ポッドが起動しない場合

```bash
# ポッドの詳細を確認
kubectl describe pod <pod-name> -n jfrog-platform

# ログを確認
kubectl logs <pod-name> -n jfrog-platform
```

### PVCがバインドされない場合

```bash
# ストレージクラスの確認
kubectl get storageclass

# PVCの詳細を確認
kubectl describe pvc <pvc-name> -n jfrog-platform
```

### イングレスが動作しない場合

```bash
# AWS Load Balancer Controllerの確認
kubectl get pods -n kube-system | grep aws-load-balancer-controller

# イングレスの詳細を確認
kubectl describe ingress jfrog-ingress -n jfrog-platform
```

## 📚 参考資料

- [JFrog Artifactory Documentation](https://www.jfrog.com/confluence/)
- [JFrog Xray Documentation](https://www.jfrog.com/confluence/display/JFROG/JFrog+Xray)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)

## 🤝 サポート

問題が発生した場合は、以下を確認してください：

1. Kubernetesクラスタの状態
2. ストレージクラスの設定
3. リソース制限
4. ネットワーク設定

詳細なログとエラーメッセージを確認することで、問題の特定が容易になります。