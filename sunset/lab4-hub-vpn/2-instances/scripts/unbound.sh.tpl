#! /bin/bash

apt update
apt install -y tcpdump unbound dnsutils

rm /etc/unbound/unbound.conf
touch /etc/unbound/unbound.log
chmod a+x /etc/unbound/unbound.log

cat <<EOF > /etc/unbound/unbound.conf

server:
        log-queries: yes
        chroot: "/etc/unbound"
        logfile: "/etc/unbound/unbound.log"
        verbosity: 3

        port: 53
        do-ip4: yes
        do-udp: yes
        do-tcp: yes

        interface: 0.0.0.0

        access-control: 0.0.0.0 deny
        access-control: 127.0.0.0/8 allow
        access-control: 10.0.0.0/8 allow
        access-control: 192.168.0.0/16 allow
        access-control: 172.16.0.0/12 allow
        access-control: ${EGRESS_PROXY} allow

        private-address: 10.0.0.0/8
        private-address: 172.16.0.0/12
        private-address: 192.168.0.0/16
        private-address: 169.254.0.0/16

        local-data: "${NAME_ONPREM_VM_A} A ${RECORD_ONPREM_VM_A}"
        local-data: "${NAME_ONPREM_VM_B} A ${RECORD_ONPREM_VM_B}"

        # redirect the following APIs to restricted.googleapis.com
        local-zone: "storage.googleapis.com" redirect
        local-zone: "bigquery.googleapis.com" redirect
        local-zone: "bigtable.googleapis.com" redirect
        local-zone: "dataflow.googleapis.com" redirect
        local-zone: "dataproc.googleapis.com" redirect
        local-zone: "cloudkms.googleapis.com" redirect
        local-zone: "pubsub.googleapis.com" redirect
        local-zone: "spanner.googleapis.com" redirect
        local-zone: "containerregistry.googleapis.com" redirect
        local-zone: "container.googleapis.com" redirect
        local-zone: "gkeconnect.googleapis.com" redirect
        local-zone: "gkehub.googleapis.com" redirect
        local-zone: "logging.googleapis.com" redirect
        local-zone: "gcr.io" redirect

        local-data: "storage.googleapis.com CNAME restricted.googleapis.com"
        local-data: "bigquery.googleapis.com CNAME restricted.googleapis.com"
        local-data: "bigtable.googleapis.com CNAME restricted.googleapis.com"
        local-data: "dataflow.googleapis.com CNAME restricted.googleapis.com"
        local-data: "dataproc.googleapis.com CNAME restricted.googleapis.com"
        local-data: "cloudkms.googleapis.com CNAME restricted.googleapis.com"
        local-data: "pubsub.googleapis.com CNAME restricted.googleapis.com"
        local-data: "spanner.googleapis.com CNAME restricted.googleapis.com"
        local-data: "containerregistry.googleapis.com CNAME restricted.googleapis.com"
        local-data: "container.googleapis.com CNAME restricted.googleapis.com"
        local-data: "gkeconnect.googleapis.com CNAME restricted.googleapis.com"
        local-data: "gkehub.googleapis.com CNAME restricted.googleapis.com"
        local-data: "logging.googleapis.com CNAME restricted.googleapis.com"
        local-data: "gcr.io CNAME restricted.googleapis.com"

        # redirect all other google apis to private.googleapis.com
        local-zone: "googleapis.com" redirect
        local-data: "googleapis.com CNAME private.googleapis.com"

forward-zone:
        name: "${NAME_LAB}"
        forward-addr: ${FORWARD_LAB_A}
        forward-addr: ${FORWARD_LAB_B}

forward-zone:
        name: "."
        forward-addr: 8.8.8.8
        forward-addr: 8.8.4.4
EOF

/etc/init.d/unbound restart
