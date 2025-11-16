#!/bin/bash


sudo apt update
sudo apt upgrade -y
# --- Kubernetes Client (kubectl) Installation ---
echo "## Installing kubectl..."
# Get the stable Kubernetes version
K8S_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
echo "   -> Stable Kubernetes version is: ${K8S_VERSION}"

echo "   -> Downloading kubectl binary..."
curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"

echo "   -> Downloading kubectl SHA-256 checksum file..."
curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl.sha256"

echo "   -> Verifying checksum..."
if ! echo "$(cat kubectl.sha256) kubectl" | sha256sum --check; then
    echo "ERROR: Checksum failed! kubectl file may be corrupted."
    exit 1
fi

echo "   -> Installing kubectl to /usr/local/bin..."
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm kubectl kubectl.sha256

echo "   -> Verifying kubectl version..."
kubectl version --client

echo ""
echo "## ⚙Installing Minikube..."
MINIKUBE_BIN="minikube-linux-amd64"

echo "   -> Downloading the latest Minikube binary..."
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/${MINIKUBE_BIN}

echo "   -> Installing Minikube to /usr/local/bin and cleaning up..."
sudo install ${MINIKUBE_BIN} /usr/local/bin/minikube
rm ${MINIKUBE_BIN}

echo "   -> Verifying Minikube installation..."
minikube version

echo ""
echo "## Starting Minikube..."
minikube start

kubectl get sa

kubectl get sa

kubectl get sa

IMAGE_NAME="franssy/weather-predictor:1.0" # e.g., myuser/my-web-app:v1
APP_NAME="weather-app"
CONTAINER_PORT=5000
SERVICE_PORT=8080
REPLICA_COUNT=3


echo "Starting Kubernetes deployment process for image: ${IMAGE_NAME}"
echo "--------------------------------------------------------"

echo "1. Creating Kubernetes Deployment: ${APP_NAME}"

kubectl create deployment ${APP_NAME} \
    --image=${IMAGE_NAME} \
    --port=${CONTAINER_PORT}

if [ $? -ne 0 ]; then
    echo "ERROR: Deployment creation failed. Exiting."
    exit 1
fi
echo "Deployment '${APP_NAME}' created successfully."

echo "---"

echo "2. Creating Kubernetes Service for external access"


kubectl expose deployment ${APP_NAME} \
    --type=NodePort \
    --name=${APP_NAME}-service \
    --port=${SERVICE_PORT} \
    --target-port=${CONTAINER_PORT} \
    --labels="app=${APP_NAME}"


NODE_PORT=$(kubectl get svc weather-app-service -o=jsonpath='{.spec.ports[*].nodePort}')

if [ $? -ne 0 ]; then
    echo "ERROR: Service creation failed. Exiting."
    exit 1
fi
echo "Service '${APP_NAME}-service' created successfully (Type: NodePort)."

echo "---"

echo "3. Scaling deployment to ${REPLICA_COUNT} replicas for Rolling Updates"

kubectl scale deployment ${APP_NAME} \
    --replicas=${REPLICA_COUNT}

if [ $? -ne 0 ]; then
    echo "ERROR: Scaling deployment failed. You might want to check the deployment name."
    exit 1
fi
echo "Deployment scaled to ${REPLICA_COUNT} replicas."

echo "---"
echo "Deployment Summary (wait a moment for resources to spin up):"
kubectl get all -l app=${APP_NAME}

kubectl port-forward --address 0.0.0.0 service/weather-app-service "${NODE_PORT}":"${SERVICE_PORT}"

echo "Script finished successfully."

