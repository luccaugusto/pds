#!/bin/bash

bundle update && 
JEKYLL_ENV=production && 
bundle exec jekyll build &&

cd _site
rm episodios/*
rm *.sh
cd ..

#sobe so o ultimo episodio, os outros ja estao no servidor
ULTIMO=$(ls episodios | tail -1)
cp episodios/$ULTIMO _site/episodios/
