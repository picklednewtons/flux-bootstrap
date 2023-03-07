export CLUSTERNAME=$(ls flux/clusters/)
mkdir "flux/apps/$CLUSTERNAME/before/namespaces" -p
mkdir "flux/apps/$CLUSTERNAME/before/helmrepos" -p

cat <<EOF > "flux/apps/$CLUSTERNAME/before/namespaces/metrics.yaml"
apiVersion: v1
kind: Namespace
metadata:
  name: metrics
EOF

cat <<EOF > "flux/apps/$CLUSTERNAME/before/namespaces/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - metrics.yaml
EOF

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

cat <<EOF > "flux/apps/$CLUSTERNAME/before/helmrepos/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - prometheus-community.yaml
EOF

cat <<EOF > "flux/apps/$CLUSTERNAME/before/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespaces
  - helmrepos
EOF

mkdir "flux/clusters/$CLUSTERNAME/apps" -p

flux create kustomization before-apps \
    --source=GitRepository/flux-system \
    --path="./flux/apps/$CLUSTERNAME/before/" \
    --prune=true \
    --interval=5m \
    --export > ./flux/clusters/$CLUSTERNAME/apps/before.yaml