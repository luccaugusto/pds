#!/bin/bash

[ -d episodios ] || mkdir episodios
[ -d monologos ] || mkdir monologos

bundle update &&
JEKYLL_ENV=production &&
bundle exec jekyll build

#sobe so o ultimo episodio, os outros ja estao no servidor
#ULTIMO=$(ls episodios | tail -1) &&
#[ "$ULTIMO" ] && cp episodios/$ULTIMO _site/episodios/ &&

#sobe so o ultimo monologo, os outros ja estao no servidor
#ULTIMO=$(ls monologos | tail -1) &&
#[ "$ULTIMO" ] && cp monologos/$ULTIMO _site/monologos/
