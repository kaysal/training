#! /bin/bash

apt update
apt install -y tcpdump unbound dnsutils

rm /etc/unbound/unbound.conf
touch /var/log/unbound.log
chmod a+x /var/log/unbound.log

cat <<EOF > /etc/unbound/unbound.conf

server:
        log-queries: yes
        logfile: /var/log/unbound.log

        verbosity: 3
        num-threads: 2

        port: 53
        do-ip4: yes
        do-udp: yes
        do-tcp: yes

        # Use this only when you downloaded the list of primary root servers!
        #root-hints: "/var/lib/unbound/root.hints"

        # Ensure kernel buffer is large enough to not lose messages in traffic spikes
        so-rcvbuf: 1m

        interface: 0.0.0.0

        access-control: 0.0.0.0 deny
        access-control: 127.0.0.0/8 allow
        access-control: 172.16.0.0/16 allow
        access-control: 10.10.1.0/24 allow
        access-control: 35.199.192.0/19 allow

        private-address: 10.0.0.0/8
        private-address: 172.16.0.0/12
        private-address: 192.168.0.0/16
        private-address: 169.254.0.0/16

        local-data: "vm.onprem.lab A 172.16.1.2"
        local-data: "ns.onprem.lab A 172.16.1.99"

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

forward-zone:
        name: "cloud.lab"
        forward-addr: 172.16.1.99

forward-zone:
        name: "."
        forward-addr: 8.8.8.8
        forward-addr: 8.8.4.4
EOF

/etc/init.d/unbound restart
