#!/bin/sh

echo "UPLOADING"
rsync -avz _site/ root@luccaaugusto.xyz:/var/www/pds.luccaaugusto.xyz/html/

echo "UPDATE GIT"
EP=$(ls _site/episodios/)
MON=$(ls _site/monologos/)

[ "$EP" ] && MSG="update relacionado a "$EP
[ "$MON" ] && MSG="update relacionado a "$MON
git add .
git commit -m "$MSG"
git push
