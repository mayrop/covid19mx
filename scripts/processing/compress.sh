#!/bin/bash

#Accept Arguments
while [[ $# -gt 1 ]]
do
key="$1"
echo $key
case $key in
    -s|-source)
    SOURCE="$2"; shift;;
esac
shift
done 

COMPRESSED_FILE=$(echo ${SOURCE} | sed -e "s/\.pdf/-c.pdf/")
echo "Compressing ${SOURCE} into ${COMPRESSED_FILE}"

# creating the txt file
if [ ! -f $COMPRESSED_FILE ]; then
    gs -q -dNOPAUSE -dBATCH -dSAFER \
        -sDEVICE=pdfwrite \
        -dCompatibilityLevel=1.3 \
        -dPDFSETTINGS=/screen \
        -dEmbedAllFonts=true \
        -dSubsetFonts=true \
        -dColorImageDownsampleType=/Bicubic \
        -dColorImageResolution=144 \
        -dGrayImageDownsampleType=/Bicubic \
        -dGrayImageResolution=144 \
        -dMonoImageDownsampleType=/Bicubic \
        -dMonoImageResolution=144 \
        -sOutputFile=$COMPRESSED_FILE $SOURCE

    echo "Removing ${SOURCE}"
    # TODO - add file size compression before commiting

    rm $SOURCE
    mv $COMPRESSED_FILE $SOURCE
fi