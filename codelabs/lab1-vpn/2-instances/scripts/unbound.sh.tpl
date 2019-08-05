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
        access-control: ${DNS_EGRESS_PROXY} allow

        private-address: 10.0.0.0/8
        private-address: 172.16.0.0/12
        private-address: 192.168.0.0/16
        private-address: 169.254.0.0/16

        local-data: "${DNS_NAME1} A ${DNS_RECORD1}"

forward-zone:
        name: "${FORWARD_ZONE1}"
        forward-addr: ${FORWARD_ZONE1_TARGET}

forward-zone:
        name: "."
        forward-addr: 8.8.8.8
        forward-addr: 8.8.4.4
EOF

/etc/init.d/unbound restart
