FROM nginx

COPY dns.sh /usr/local/bin/
COPY dns.sh /tmp/
RUN chmod a+x /usr/local/bin/dns.sh
RUN apt-get update
RUN apt-get install -y dnsutils fping curl wget
RUN apt-get clean
