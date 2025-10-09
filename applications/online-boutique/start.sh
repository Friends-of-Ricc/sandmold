#!/usr/bin/env bash
set -e
set -o pipefail

echo "--- Starting Online Boutique Deployment ---"

# Check for required environment variables
: "${PROJECT_ID?PROJECT_ID not set}"
: "${CLUSTER_NAME?CLUSTER_NAME not set}"
: "${CLUSTER_LOCATION?CLUSTER_LOCATION not set}"

echo "--> Configuring kubectl for project ${PROJECT_ID} and cluster ${CLUSTER_NAME}..."
gcloud container clusters get-credentials "${CLUSTER_NAME}" --region "${CLUSTER_LOCATION}" --project "${PROJECT_ID}"

ONLINE_BOUTIQUE_DIR="vendor/microservices-demo"
if [ ! -d "$ONLINE_BOUTIQUE_DIR" ]; then
    echo "--> Cloning Online Boutique repository..."
    git clone --depth 1 https://github.com/GoogleCloudPlatform/microservices-demo.git "$ONLINE_BOUTIQUE_DIR"
else
    echo "--> Online Boutique repository already exists."
fi

echo "--> Deploying Online Boutique manifests..."
kubectl apply -f "${ONLINE_BOUTIQUE_DIR}/release/kubernetes-manifests.yaml"

echo "--> Waiting for application frontend to get an external IP..."
EXTERNAL_IP=""
while [ -z "$EXTERNAL_IP" ]; do
  echo "Waiting for end point..."
  EXTERNAL_IP=$(kubectl get service frontend-external -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  [ -z "$EXTERNAL_IP" ] && sleep 10
done

echo "--- ✅ Online Boutique Deployed Successfully ---"
echo "Application frontend is available at: http://${EXTERNAL_IP}"