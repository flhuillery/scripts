### RETIRER LES COMMENTAIRES D'UN FICHIER DE CONFIGURATION

# Variables
folder="/dossier/"
fichier="fichier.conf"

# Copie de sauvegarde
cp $folder$fichier $folder$fichier.old

# Retrait des commentaires
sed '/^#/d' $folder$fichier
