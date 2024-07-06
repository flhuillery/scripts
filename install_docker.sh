#!/bin/bash

# Add Docker's official GPG key:
apt-get update
apt-get -y dist-upgrade
apt-get -y install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker engine & compose
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose gpg

# Run Docker Hello World
 docker run --name hello-world -d hello-world

# Destruction du docker
read -p "Voulez-vous supprimer Docker ? (o/n) : " reponse
if [ "$reponse" == "o" ]; then
    echo "Suppression du Docker..."
    docker rm -f hello-world
    docker image rm -f hello-world
else
    echo "Opération annulée. Docker n'a pas été supprimé."
fi

# Add user docker
/sbin adduser dockeruser
echo "Entrer le mot de passe pour l'utilisateur dockeruser"
passwd dockeruser
/sbin/sbinusermod -aG docker dockeruser

# Rebbot
read -p "Voulez-vous reboot ? (o/n) : " reponse
if [ "$reponse" == "o" ]; then
    /sbin/reboot
else
    echo "Reboot annulée."
fi
