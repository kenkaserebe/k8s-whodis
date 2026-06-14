# k8s-whodis/README.md

# k8s-whodis 🐳 ➡️ 🎯

**A sample web server for testing Grafana/Prometheus monitoring in Kubernetes**

k8s-whodis is a lightweight Python Flask application that displays the pod hostname (container ID) on a stylish webpage. It's designed specifically to help you validate monitoring stacks, load balancing, and Kubernetes deployments - perfect for testing Prometheus metrics collection, Grafana dashboards, and ArgoCD sync policies.

---

#### ✨ Features

- **Pod Identification** - Displays its own Kubernetes pod name/hostname on a modern web UI
- **Health Checks** - Built-in liveness & readiness probes for Kubernetes
- **Load Balancing Test** - Run multiple replicas to verify traffic distribution
- **Prometheus Ready** - Easily add metrics endpoints for scraping
- **ArgoCD Compatible** - Includes Application CRD for GitOps deployments
- **Traefik Ingress** - Ready-to-use ingress configuration
- **Resource Limits** - Pre-configured CPU/memory requests & limits

---

#### 🏗️ Architecture

User → Ingress (Traefik) → Service (ClusterIP) → Pods (2 replicas)
↓
Flask App on port 5000
↓
Returns Pod Hostname

---

#### 📋 Prerequisites

- Kubernetes cluster (v1.20+)
- 'kubectl' configured with cluster access
- Traefik as ingress controller (Optional)
- ArgoCD for GitOps deployment (Optional)
- Prometheus + Grafana for monitoring (Optional)

---

#### 🚀 Quick Start

### 1. Clone the Repository

'''bash

git clone https://github.com/kenkaserebe/k8s-whodis.git
cd k8s-whodis


### 2. Apply Kubernetes Manifests

# Create namespace and all resources
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml


### 3. Verify Deployment

# Check pods are running
kubectl get pods -n k8s-whodis

# Check service endpoints
kubectl get svc -n k8s-whodis

# Check ingress
kubectl get ingress -n k8s-whodis


### 4. Access the Application
    - Direct Pod Access (port-forwar):
        '''bash
        kubectl port-forward -n k8s-whodis deployment/k8s-whodis 5000:5000
        # Then open http://localhost:5000

    - Via Ingress (if Traefik is configured):
        '''bash
        curl http://192.168.1.15/   # Replace with your ingress IP


#### 🔧 Configuration

# Node Label Requirement

The deployment uses nodeSelector to schedule pods on worker nodes with the label role=worker:

'''bash

kubectl label nodes <your-worker-node> role=worker


# Environment Variables

You can override the display pod name by adding to deployment.yaml:

'''yaml

env:
    -   name: POD_NAME
        value: "custom-name"


# Resource Limits

Current defaults (adjust in deployment.yaml):

'''yaml

requests:
    memory: "64Mi"
    cpu: "100m"
limits:
    memory: "128Mi"
    cpu: "200m"


# Endpoints

Endpoint                        Method                  Description
----------------------------------------------------------------------------------------------
/                               GET                     Returns HTML page with pod hostname
----------------------------------------------------------------------------------------------
/hostname                       GET                     Returns plain text pod hostname
----------------------------------------------------------------------------------------------


#### 🐳 Building the Container Image

If you want to modify the application:

'''bash

# Build image
docker build -t your-registry/k8s-whodis:python-v1 .

# Push to registry
docker push your-registry/k8s-whodis:python-v1

# Update deployment.yaml image field

Current image: docker.io/ken0k/k8s-whodis:python-v1



#### 📊 Monitoring with Prometheus & Grafana

# Add Metrics Endpoint (Optional Enhancement)

To collect metrics, add this to app.py:

'''python

from prometheus_flask_exporter import PrometheusMetrics
metrics = PrometheusMetrics(app)
metrics.info('app_info', 'Application info', version='1.0.0')


Then add a ServiceMonitor for Prometheus:

'''yaml

apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
    name: k8s-whodis
spec:
    selector:
        matchLabels:
            app: k8s-whodis
    endpoints:
        -   port: http
            path: /metrics


### Test Load Balancing

Generate traffic to see pod distribution:

'''bash

# Continuous requests to see different pod names
while true; do
    curl http://192.168.1.15/hostname
    sleep 1
done



#### 🔄 ArgoCD Deployment

The repository includes an ArgoCD Application manifest:

'''bash

kubectl apply -f argocd-application.yaml


## Sync Policy Features:

- Automated sync with prune & self-heal
- Creates namespace automatically
- Prune propagation foreground
- Retains 5 revision history


#### 🧪 Testing Your Monitoring Stack

With k8s-whodis you can validate:

1. Service Discovery - Ensure Prometheus finds pod endpoints
2. Load Balancing - Verify traffic splits across replicas
3. Health Checks - Test liveness/readiness probe behavior
4. Auto-scaling - Simulate load with multiple requests
5. Ingress Routing - Confirm Traefik routes correctly
6. ArgoCD Sync - Test GitOps reconciliation


#### 📁 Project Structure


# k8s-whodis/folder_structure

k8s-whodis/
|---templates/
|   |---index.html          # The static webpage with "Hello from [pod name/hostname]"
|
|---k8s/
|   |---namespace.yaml      # Kubernetes namespace for this project
|   |---deployment.yaml     # Pod template, replicas, container spec, probes
|   |---service.yaml        # Internal service to expose the deployment
|   |---ingress.yaml        # External access (to make it public)
|
|---app.py
|---argocd-application.yaml
|---Dockerfile              # Container build instructions
|---requirements.txt        # Python dependencys to be installed
|---README.md               # Project documentation


#### Troubleshooting

Issue                           Solution
-----------------------------------------------------------------------------------------------
Pods stuck in Pending           Check node selector labels:
                                kubectl get nodes --show-labels
-----------------------------------------------------------------------------------------------
Ingress not working             Verify Traefik is running:
                                kubectl get pods -n traefik
-----------------------------------------------------------------------------------------------
Image pull error                Ensure image is public or use imagePullSecrets
-----------------------------------------------------------------------------------------------
Liveness probe failing          Check if port 5000 is exposed and / endpoint responds
-----------------------------------------------------------------------------------------------


### Debug commands:

'''bash

# Check pod logs
kubectl logs -n k8s-whodis -l app=k8s-whodis

# Describe pod for events
kubectl describe pod -n k8s-whodis -l app=k8s-whodis

# Port forward for direct testing
kubectl port-forward -n k8s-whodis svc/k8s-whodis 5000:5000



#### 🤝 Contributing

This is a testing/demo project, but contributions are welcome!

1. Fork the repository
2. Create a feature branch (git checkout -b feature/amazing-feature)
3. Commit changes (git commit -m "Add amazing feature")
4. Push to branch (git push origin feature/amazing-feature)
5. Open a Pull Request


#### 🙏 Acknowledgements

- Built with [Flask](https://flask.palletsprojects.com/)
- Deployed on [Kubernetes](https://kubernetes.io/)
- Monitored with [Prometheus](https://prometheus.io/)
- Monitored with [Grafana](https://grafana.com/)
- Managed via [ArgoCD](https://argoproj.github.io/cd/)


#### 📬 Contact

Project Link: https://github.com/kenkaserebe/k8s-whodis


Happy Monitoring! 🔍📊