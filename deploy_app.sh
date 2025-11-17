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

sleep 5 # Waits for 5 seconds

kubectl apply -f weather-app.yaml

sleep 20

kubectl port-forward --address 0.0.0.0 service/weather-app-service "30080":"8080"

echo "Script finished successfully."

