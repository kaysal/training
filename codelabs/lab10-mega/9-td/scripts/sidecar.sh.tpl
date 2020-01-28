#! /bin/bash

# Add a system user to run Envoy binaries. Login is disabled for this user
sudo adduser --system --disabled-login ${ENVOY_USER}

# Download and extract the Traffic Director tar.gz file
sudo wget -P /home/envoy https://storage.googleapis.com/traffic-director/traffic-director.tar.gz
sudo tar -xzf /home/envoy/traffic-director.tar.gz -C /home/envoy

sudo cat << END > /home/envoy/traffic-director/sidecar.env
ENVOY_USER=${ENVOY_USER}
# Exclude the proxy user from redirection so that traffic doesn't loop back
# to the proxy
EXCLUDE_ENVOY_USER_FROM_INTERCEPT='true'
# Intercept all traffic by default
SERVICE_CIDR='${SERVICE_CIDR}'
GCP_PROJECT_NUMBER='${GCP_PROJECT_NUMBER}'
VPC_NETWORK_NAME='${VPC_NETWORK_NAME}'
ENVOY_PORT='${ENVOY_PORT}'
ENVOY_ADMIN_PORT='${ENVOY_ADMIN_PORT}'
LOG_DIR='/var/log/envoy/'
LOG_LEVEL='info'
XDS_SERVER_CERT='/etc/ssl/certs/ca-certificates.crt'
END

sudo apt-get update -y
sudo apt-get install tcpdump apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/debian stretch stable' -y
sudo apt-get update -y
sudo apt-get install docker-ce apache2 -y
vm_hostname="$(curl -H "Metadata-Flavor:Google" http://169.254.169.254/computeMetadata/v1/instance/name)"
echo "$vm_hostname" | tee /var/www/html/index.html
sudo service apache2 restart

sudo /home/envoy/traffic-director/pull_envoy.sh
sudo /home/envoy/traffic-director/run.sh start

iptables -A FORWARD -i eth0 -j ACCEPT
iptables -A INPUT -i eth0 -j ACCEPT

touch /usr/local/bin/directz
chmod a+x /usr/local/bin/directz
cat <<EOF > /usr/local/bin/directz
echo "wget -q --header 'Host: service' -O - 10.10.10.10; echo"
wget -q --header 'Host: service' -O - 10.10.10.10; echo
EOF
