#!/bin/bash
DockerComposeRepo="https://raw.githubusercontent.com/LanOps/teamspeak-docker-compose/master/docker-compose.yml"
# Download and install Docker
curl -fsSL https://get.docker.com -o get-docker.sh | sh get-docker.sh
# Download docker compose file
curl -fsSL $DockerComposeRepo -o compose.yaml
# Add User to Docker group
sudo usermod -aG docker $USER
# Start dockercompose
docker compose up -d
# Portainer aufsetzten
docker volume create portainer_data
docker run -d -p 9000:9000  --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
# Traefik testcontainer
docker run -d -p 1234:80 traefik/whoami

##############
# DNS-Bims
##############
# Bind installieren
apt install bind9
# Systemd-resolv abschalten
systemctl stop systemd-resolved.service && systemctl disable systemd-resolved.service
# /etx/resolv.conf löschen
rm /etc/resolv.conf
cat > /etc/resolv.conf << EOF
nameserver 8.8.8.8
options edns0 trust-ad
search m300.smartlearn.ch
EOF
# Install DNS-Server standalone
cat > /etc/bind/named.conf.options << EOF
options {
	directory "/var/cache/bind";
	forwarders {
		8.8.8.8;
	};
	allow-recursion {
		192.168.210.0/24;
		192.168.220.0/24;
	};
    dnssec-validation no;
    listen-on-v6 { };
	auth-nxdomain no;       # conform to RFC1035
    empty-zones-enable no;  # less noise in log
};
EOF
cat > /etc/bind/named.conf.local << EOF
// lokale zonen
//

zone "lan.m300.smartlearn.ch" {
	type master;
	file "/etc/bind/db.lan.m300.smartlearn.ch";
};

// lokale zonen
// reverse

zone "220.168.192.in-addr.arpa" {
	type master;
	file "/etc/bind/db.192.168.220";
};

zone "210.168.192.in-addr.arpa" {
	type master;
	file "/etc/bind/db.192.168.210";
};
EOF
cat > /etc/bind/db.lan.m300.smartlearn.ch << EOF
$ttl 3600
lan.m300.smartlearn.ch. IN      SOA     ns.m300.smartlearn.ch. root.m300.smartlearn.ch. (
                        2024020802
                        3600
                        600
                        1209600
                        3600 )
lan.m300.smartlearn.ch. IN      NS      ns.m300.smartlearn.ch.
test    IN A 3.4.5.6
vmls4 IN A 192.168.210.64
vmls5 IN A 192.168.210.65
vmwp1 IN A 192.168.210.10
EOF
cat > /etc/bind/db.192.168.210 << EOF
; BIND data file for 210.168.192.in-addr.arpa
;
$TTL 86400      ; (1 day)
@       IN      SOA     ns.m300.smartlearn.ch. root.m300.smartlearn.ch. (
                        2024020801
                        14400
                        1800
                        1209600
                        3600 )
;
@       172800  IN      NS      ns.m300.smartlearn.ch.
1       IN      PTR     vmlf1.lan.m300.smartlearn.ch.
99       IN      PTR     test99.smartlearn.lan.
EOF

# Restart bind
sudo systemctl restart named
