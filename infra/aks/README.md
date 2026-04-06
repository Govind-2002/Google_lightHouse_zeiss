# Deploy Lighthouse Audit Service To AKS (Docker Hub)

This guide deploys the Lighthouse Audit Service and Postgres to AKS using the manifests in this folder.

## 1. Prerequisites

Install and verify:

- Azure CLI (`az`)
- Kubectl (`kubectl`)
- Docker (`docker`)

Login:

```bash
az login
az account set --subscription <SUBSCRIPTION_ID>
```

## 2. Connect To Existing AKS Cluster

Set variables:

```bash
RG=<AKS_RESOURCE_GROUP>
AKS_NAME=aks-sre-peacemaker-dev
```

Fetch kubeconfig for your existing cluster:

```bash
az aks get-credentials --resource-group $RG --name $AKS_NAME --overwrite-existing
```

## 3. Build and Push Lighthouse Image To Docker Hub

If you are using the Spotify repo source directly, clone it first:

```bash
git clone https://github.com/spotify/lighthouse-audit-service.git
cd lighthouse-audit-service
```

Set Docker Hub variables and build:

```bash
DOCKERHUB_USERNAME=<your-dockerhub-username>
IMAGE_TAG=$(date +%Y%m%d%H%M)
IMAGE_NAME=$DOCKERHUB_USERNAME/lighthouse-audit-service:$IMAGE_TAG

docker login
docker build -t $IMAGE_NAME .
docker push $IMAGE_NAME
```

If your Docker Hub repository is private, create an image pull secret in Kubernetes:

```bash
kubectl create secret docker-registry dockerhub-pull-secret \
  --namespace lighthouse \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=<your-dockerhub-username> \
  --docker-password=<your-dockerhub-password-or-token> \
  --docker-email=<your-email>
```

## 4. Update Kubernetes Image Reference

Edit `lighthouse.yaml` and replace `REPLACE_WITH_DOCKERHUB_IMAGE` with the pushed image.

Example:

```text
your-dockerhub-username/lighthouse-audit-service:202603091800
```

## 5. Set Database Secret

Update `secret.yaml` with a strong value for `POSTGRES_PASSWORD`.

## 6. Deploy To AKS

From this folder (`infra/aks`):

```bash
kubectl apply -k .
```

If your Docker Hub repository is private, uncomment `imagePullSecrets` in `lighthouse.yaml` before applying.

Check rollout:

```bash
kubectl get pods -n lighthouse
kubectl get svc -n lighthouse
kubectl rollout status deploy/postgres -n lighthouse
kubectl rollout status deploy/lighthouse-audit-service -n lighthouse
```

Fetch external URL:

```bash
kubectl get svc lighthouse-audit-service -n lighthouse -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Service URL:

```text
http://<EXTERNAL_IP>
```

## 7. Smoke Test

Trigger an audit:

```bash
curl -X POST http://<EXTERNAL_IP>/v1/audits \
  -H "Content-Type: application/json" \
  -d '{"url":"https://www.zeiss.com"}'
```

## 8. Recommended Hardening (Next)

- Use Azure Database for PostgreSQL instead of in-cluster Postgres.
- Move secrets to Azure Key Vault + CSI driver.
- Add an Ingress (Nginx/Application Gateway) with TLS.
- Add HPA and PodDisruptionBudget.
- Add image scanning and signed image enforcement in CI/CD.
