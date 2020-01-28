#! /bin/bash

export SVC=app-svc
export SUBDOMAIN=${SVC}
export HOSTNAMES=(pod1 pod2)

echo ""
echo "INFO: $i"
echo "----------------------------------------"
echo "NODE_NAME = $NODE_NAME"
echo "NODE_IP   = $HOST_IP"
echo "POD_NAME  = $NAME"
echo "POD_IP    = $POD_IP"
echo "NAMESPACE = $NAMESPACE"
echo "SVC_ACCT  = $SERVICE_ACCOUNT_NAME"

for i in "${HOSTNAMES[@]}"
do
  echo ""
  echo "TEST: $i"
  echo "----------------------------------------"
  echo "fping -A $i.${SUBDOMAIN}.default.svc.cluster.local"
  fping -A $i.${SUBDOMAIN}.default.svc.cluster.local
done

echo ""
echo "TEST: ${SVC}.default.svc.cluster.local"
echo "----------------------------------------"
echo "dig +noall +answer ${SVC}.default.svc.cluster.local"
dig +noall +answer ${SVC}.default.svc.cluster.local
echo ""
echo "fping -A ${SVC}.default.svc.cluster.local"
fping -A ${SVC}.default.svc.cluster.local
