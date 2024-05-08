#!/bin/bash

# Demande s'il veut supprimer Docker
read -p "Voulez-vous supprimer Docker ? (o/n) : " reponse

# Vérifie si la réponse est "o" (pour oui)
if [ "$reponse" == "o" ]; then
    echo "Suppression du Docker..."
    docker rm -f hello-world
    docker image rm -f hello-world
else
    echo "Opération annulée. Docker n'a pas été supprimé."
fi
