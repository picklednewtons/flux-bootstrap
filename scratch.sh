# Prepare folder structure
export CLUSTERNAME=$(ls flux/clusters/)
mkdir "flux/apps/$CLUSTERNAME/before/namespaces" -p
mkdir "flux/apps/$CLUSTERNAME/before/helmrepos" -p
mkdir "flux/clusters/$CLUSTERNAME/apps" -p

# Metrics namespace yaml
cat <<EOF > "flux/apps/$CLUSTERNAME/before/namespaces/metrics.yaml"
apiVersion: v1
kind: Namespace
metadata:
  name: metrics
EOF

# Kustomization reference to install Namespaces
cat <<EOF > "flux/apps/$CLUSTERNAME/before/namespaces/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - metrics.yaml
EOF

# Helm repository source for kube-state-metrics
cat <<EOF > "flux/apps/$CLUSTERNAME/before/helmrepos/prometheus-community.yaml"
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  namespace: flux-system
  name: prometheus-community
spec:
  interval: 30m
  url: https://prometheus-community.github.io/helm-charts
EOF

# Kustomization reference to install Helm Repositories
cat <<EOF > "flux/apps/$CLUSTERNAME/before/helmrepos/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - prometheus-community.yaml
EOF

# Kustomization reference to install resources required BEFORE app installation
cat <<EOF > "flux/apps/$CLUSTERNAME/before/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespaces
  - helmrepos
EOF

# Kustomization proper to install BEFORE resources
flux create kustomization before-apps \
    --source=GitRepository/flux-system \
    --path="./flux/apps/$CLUSTERNAME/before/" \
    --prune=true \
    --interval=5m \
    --export > ./flux/clusters/$CLUSTERNAME/apps/before.yaml

mkdir "flux/apps/$CLUSTERNAME/kube-state-metrics" -p

# Create HlemReslease source for kube-state-metrics
flux create hr kube-state-metrics \
    --interval=10m \
    --source=HelmRepository/prometheus-community \
    --chart=kube-state-metrics \
    --chart-version=">4.30.0" \
    --export > ./flux/apps/$CLUSTERNAME/kube-state-metrics/kube-state-metrics.helm.yaml

# Kustomization reference to install resources required BEFORE app installation
cat <<EOF > "flux/apps/$CLUSTERNAME/kube-state-metrics/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - kube-state-metrics.helm.yaml
EOF

# Kustomization proper to install BEFORE resources
flux create kustomization kube-state-metrics \
    --source=GitRepository/flux-system \
    --namespace=metrics \
    --path="./flux/apps/$CLUSTERNAME/kube-state-metrics/" \
    --prune=true \
    --interval=5m \
    --export > ./flux/clusters/$CLUSTERNAME/apps/kube-state-metrics.yaml
