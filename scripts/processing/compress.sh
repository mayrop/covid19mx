#!/bin/bash

#Accept Arguments
while [[ $# -gt 1 ]]
do
key="$1"
case $key in
    -s|--source)
    source_file="$2"; shift;;
    -o|--overwrite)
    overwrite="$2"; shift;;  
esac
shift
done 


compressed_file=$(echo ${source_file} | sed -e "s/\.pdf/-c.pdf/")

# compressing the pdf file if it does not exist
if [ ! -f $compressed_file ]; then
    # see https://stackoverflow.com/questions/16530510/pdf-compression-like-smallpdf-com-programmatically-in-c-sharp
    echo "Compressing ${source_file} into ${compressed}"

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
        -sOutputFile=$compressed_file $source_file

    size_compressed_file=$(du -h "$compressed_file" | cut -f1)
    size_source_file=$(du -h "$source_file" | cut -f1)

    echo "source_file file size: ${size_source_file}" 
    echo "compressed file size: ${size_compressed_file}"
fi


# overwriting original file if required
if [[ $overwrite ]]; then
    if [ -f $compressed_file ]; then
        echo "Overwritring ${source_file} with compressed ${compressed}"
        rm $source_file
        mv $compressed_file $source_file
    fi
fi