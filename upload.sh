#!/bin/sh

#sobe so o ultimo episodio e monologo, os outros ja estao no servidor
ep=$(ls episodios | tail -1) &&
[ "$ep" ] &&
rsync -avz "episodios/$ep" root@luccaaugusto.xyz:/var/www/pds.luccaaugusto.xyz/html/episodios &&

mono=$(ls monologos | tail -1) &&
[ "$mono" ] &&
rsync -avz "monologos/$mono" root@luccaaugusto.xyz:/var/www/pds.luccaaugusto.xyz/html/monologos &&

# dispara CICD
git push
