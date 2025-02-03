1-
Install kubernetes with ansible:
 sudo apt update
 sudo apt install git python3 python3-pip -y
 git clone https://github.com/kubernetes-incubator/kubespray.git
 cd kubespray
 pip3 install -r requirements.txt

 cp -rfp inventory/sample inventory/mycluster
declare -a IPS=(37.32.5.249  192.168.1.243 194.5.206.64 194.5.192.765)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
vim inventory/mycluster/hosts.yaml
vi inventory/mycluster/group_vars/k8s_cluster/addons.yml
.
.
.

ansible-playbook -i inventory/mycluster/hosts.yaml  --become  --user=root --become-user=root cluster.yml

2-

install postgresql pod(single):
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
export PG_HOST="my-postgres-postgresql"
export PG_PORT="5432"
export PG_USER="postgres"
export PG_PASSWORD="mysecretpassword"
export PG_DB="mydb"
export MINIO_ACCESS_KEY="<your-minio-access-key>"
export MINIO_SECRET_KEY="<your-minio-secret-key>"
export MINIO_BUCKET="mybucket"
export BACKUP_DIR="/tmp/backups"

set bakup name with date:
export BACKUP_FILE="${BACKUP_DIR}/$(date +%F)-${PG_DB}.sql"


mkdir -p ${BACKUP_DIR}
PGPASSWORD=${PG_PASSWORD} pg_dump -h ${PG_HOST} -U ${PG_USER} ${PG_DB} > ${BACKUP_FILE}

mc alias set myminio http://<minio-server-ip>:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}
mc cp ${BACKUP_FILE} myminio/${MINIO_BUCKET}/backups/

rm ${BACKUP_FILE}

if total process in one line:
export PG_HOST="my-postgres-postgresql" PG_PORT="5432" PG_USER="postgres" PG_PASSWORD="mysecretpassword" PG_DB="mydb" MINIO_ACCESS_KEY="<your-minio-access-key>" MINIO_SECRET_KEY="<your-minio-secret-key>" MINIO_BUCKET="mybucket" BACKUP_DIR="/tmp/backups" BACKUP_FILE="${BACKUP_DIR}/$(date +%F)-${PG_DB}.sql" && mkdir -p ${BACKUP_DIR} && PGPASSWORD=${PG_PASSWORD} pg_dump -h ${PG_HOST} -U ${PG_USER} ${PG_DB} > ${BACKUP_FILE} && mc alias set myminio http://<minio-server-ip>:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY} && mc cp ${BACKUP_FILE} myminio/${MINIO_BUCKET}/backups/ && rm ${BACKUP_FILE}

3-

install prometheus & grafana:
 helm install prometheus prometheus-community/kube-prometheus-stack   --namespace monitoring   --set prometheus.service.type=NodePort   --set prometheus.service.nodePort=30090   --set grafana.service.type=NodePort   --set grafana.service.nodePort=30091
install postgres-exporter:
helm install postgres-exporter prometheus-community/prometheus-postgres-exporter \
  --namespace  default \
  --set service.type=NodePort \
  --set service.nodePort=30092 \
  --set config.datasource.host="my-postgres-postgresql.default.svc.cluster.local" \
  --set config.datasource.user="postgres" \
  --set config.datasource.passwordSecret.name="my-postgres-postgresql " \
  --set config.datasource.passwordSecret.key="postgres-password" \
  

 
