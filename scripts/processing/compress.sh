#!/bin/bash

#Accept Arguments
while [[ $# -gt 1 ]]
do
key="$1"
case $key in
    -s|--source)
    SOURCE="$2"; shift;;
    -o|--overwrite)
    OVERWRITE="$2"; shift;;  
esac
shift
done 


COMPRESSED=$(echo ${SOURCE} | sed -e "s/\.pdf/-c.pdf/")

# compressing the pdf file if it does not exist
if [ ! -f $COMPRESSED ]; then
    # see https://stackoverflow.com/questions/16530510/pdf-compression-like-smallpdf-com-programmatically-in-c-sharp
    echo "Compressing ${SOURCE} into ${COMPRESSED}"

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
        -sOutputFile=$COMPRESSED $SOURCE

    SIZE_COMPRESSED=$(du -h "$COMPRESSED" | cut -f1)
    SIZE_SOURCE=$(du -h "$SOURCE" | cut -f1)

    echo "Source file size: ${SIZE_SOURCE}" 
    echo "Compressed file size: ${SIZE_COMPRESSED}"
fi


# overwriting original file if required
if [[ $OVERWRITE ]]; then
    if [ -f $COMPRESSED ]; then
        echo "Overwritring ${SOURCE} with compressed ${COMPRESSED}"
        rm $SOURCE
        mv $COMPRESSED $SOURCE
    fi
fi