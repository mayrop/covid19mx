#!/bin/bash

# see https://stackoverflow.com/questions/18649512/unicodedecodeerror-ascii-codec-cant-decode-byte-0xe2-in-position-13-ordinal
# see https://github.com/tianon/docker-brew-debian/issues/45

DIRECTORY=$(cd `dirname $0` && pwd)
ROOT=$(dirname $DIRECTORY)
ROOT=$(dirname $ROOT)

DATA_DIRECTORY="www"
ROOT_DATA_DIRECTORY="${ROOT}/${DATA_DIRECTORY}/tablas-diarias"

cd $ROOT

python ./scripts/processing/download.py

# processing each pdf file
for FILE in `find $ROOT_DATA_DIRECTORY -name "*.pdf" | grep -E "sospechosos|positivos"`
do
    BASENAME="$(basename -- $FILE)"
    FILE_DIR="$(dirname "${FILE}")"

    TXT_FILE=$(echo ${FILE} | sed -e "s/\.pdf/.txt/")
    CSV_FILE=$(echo ${FILE} | sed -e "s/\.pdf/.csv/")

    # creating the txt file
    if [ ! -f $TXT_FILE ]; then
        echo "Creating ${TXT_FILE}"
        pdftotext -layout $FILE $TXT_FILE
    fi

    # processing the html file
    if [ ! -f $CSV_FILE ]; then
        echo "Creating ${CSV_FILE}"
        echo "python ./scripts/processing/parse.py \"${TXT_FILE}\" \"${CSV_FILE}\""
        python ./scripts/processing/parse_pdf.py "${TXT_FILE}" "${CSV_FILE}"
    fi
done

# processing each pdf file
for ORIG_FILE in `find . -iname "*.pdf" -mmin -60 -print`
do
    COMPRESSED_FILE=$(echo ${ORIG_FILE} | sed -e "s/\.pdf/compressed.pdf/")
    echo "Compressing ${ORIG_FILE} into ${COMPRESSED_FILE}"

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
            -sOutputFile=$COMPRESSED_FILE $ORIG_FILE

        echo "Removing ${ORIG_FILE}"
        # TODO - add file size compression before commiting

        rm $ORIG_FILE
        mv $COMPRESSED_FILE $ORIG_FILE
    fi
done
