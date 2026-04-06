# Instalara toda la infraestrucutra de Kubernetes usando helm
## Que se planea que descargue:

### Prometheus + grafana
### Bases de datos
### APP flask
### Dashboards

#!/bin/bash
cd bootstrap

rm -rf Chart.lock
rm -rf charts

helm dependency update

cd ..

helm upgrade --install bootstrap bootstrap

sleep 20

cd monitoring-stack

rm -rf Chart.lock
rm -rf charts

helm dependency update

cd ..

helm upgrade --install monitoring-stack monitoring-stack

sleep 20

cd databases

rm -rf Chart.lock
rm -rf charts

helm dependency update

cd ..

# Fix para conflicto de Elasticsearch con el operador
kubectl annotate elasticsearch ic4302 meta.helm.sh/release-name=databases --overwrite -n default 2>/dev/null || true
kubectl annotate elasticsearch ic4302 meta.helm.sh/release-namespace=default --overwrite -n default 2>/dev/null || true

kubectl annotate elasticsearch ic4302 meta.helm.sh/release-name=databases --overwrite -n default 2>/dev/null || true
kubectl annotate elasticsearch ic4302 meta.helm.sh/release-namespace=default --overwrite -n default 2>/dev/null || true
kubectl label elasticsearch ic4302 app.kubernetes.io/managed-by=Helm --overwrite -n default 2>/dev/null || true

helm upgrade --install databases databases 

sleep 60

helm upgrade --install app app
sleep 20

cd grafana-config
rm -rf Chart.lock
rm -rf charts
helm dependency update
cd ..

# Fix para conflicto de namespace en grafana-config
helm uninstall grafana-config -n default 2>/dev/null || true
helm upgrade --install grafana-config grafana-config -n monitoring