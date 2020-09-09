#!/bin/bash

bundle update && 
JEKYLL_ENV=production && 
bundle exec jekyll build &&

cd _site
rm episodios/*.mp3
rm monologos/*.mp3
rm *.sh
cd ..

#sobe so o ultimo episodio, os outros ja estao no servidor
ULTIMO=$(ls episodios | tail -1)
cp episodios/$ULTIMO _site/episodios/

#sobe so o ultimo monologo, os outros ja estao no servidor
ULTIMO=$(ls monologos | tail -1)
cp monologos/$ULTIMO _site/monologos/
