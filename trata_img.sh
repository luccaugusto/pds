#!/bin/sh

MARCA='portfolio.luccaaugusto.xyz'

#Compressao
comprimir_tudo()
{
	pastas=("portfolio" "piadas" "images")
	for DIR in ${pastas[@]}
	do
		for img in $(ls $DIR | grep png)
		do
			#remove extension
			name=${img%.*}
			convert -background black -alpha remove -strip -interlace Plane -gaussian-blur 0.05 -quality 50% -scale 25% $DIR/$img $DIR/$name.jpg
		done
	done
}

comprimir()
{
	img=$1
	#remove extension
	name=${img%.*}
	convert -background black -alpha remove -strip -interlace Plane -gaussian-blur 0.05 -quality 50% -scale 25% $img $name.jpg
}

#marca dagua
marca_dagua_tudo()
{
	pastas=("portfolio" "piadas")
	for DIR in ${pastas[@]}
	do
		for img in $(ls $DIR | grep jpg)
		do
			convert -size 140x80 xc:none -fill '#80808080'\
				-gravity NorthWest -draw "text 10,10 $MARCA" \
				-gravity SouthEast -draw "text 5,15 $MARCA" \
				miff:- |\
				composite -tile - $DIR/$img $DIR/aux.jpg
			rm $DIR/$img
			mv $DIR/aux.jpg $DIR/$img
		done
	done
}

marca_dagua()
{
	img="$1"
	convert -size 140x80 xc:none -fill '#80808080'\
		-gravity NorthWest -draw "text 10,10 $MARCA" \
		-gravity SouthEast -draw "text 5,15 $MARCA" \
		miff:- |\
		composite -tile - $img aux.jpg
	rm $img
	mv aux.jpg $img
}

ajuda()
{
	echo "trata_img [ option ] [ arg ]"
	echo " 			-c img: comprime imagem"
	echo "			-m img: marca dagua na imagem"
	echo "			-a: comprime todas as imagens"
	echo "			-b: marca dagua em todas as imagens"
}


case $1 in
	-c) comprimir $2
		;;
	-m) marca_dagua $2
		;;
	-a) comprimir_tudo
		;;
	-b) marca_dagua_tudo
		;;
	*) ajuda
esac
