#!/bin/bash

DIRECTORY=$(cd `dirname $0` && pwd)
ROOT=$(dirname $DIRECTORY)
ROOT=$(dirname $ROOT)

DATA_DIRECTORY="www"
ROOT_DATA_DIRECTORY="${ROOT}/${DATA_DIRECTORY}/tablas-diarias"

cd $ROOT

# processing each pdf file
for FILE in `find $ROOT_DATA_DIRECTORY -name "*.pdf" | grep -E "sospechosos|positivos"`
do
    BASENAME="$(basename -- $FILE)"
    FILE_DIR="$(dirname "${FILE}")"

    TXT_FILE=$(echo ${FILE} | sed -e "s/\.pdf/.txt/")
    HTML_FILE=$(echo ${FILE} | sed -e "s/\.pdf/.html/")
    CSV_FILE=$(echo ${FILE} | sed -e "s/\.pdf/.csv/")

    # creating the txt file
    if [ ! -f $TXT_FILE ]; then
        docker run --rm -i kadock/pdftotext < $FILE > $TXT_FILE
    fi

    # creating the html file
    if [ ! -f $HTML_FILE ]; then
        docker run -ti --rm -v $FILE_DIR:/pdf bwits/pdf2htmlex pdf2htmlEX --zoom 1.3 $BASENAME
    fi

    # processing the html file
    if [ ! -f $CSV_FILE ]; then
        echo "Processing ${CSV_FILE}"
        # TODO double check txt exists
        `python scripts/processing/parse.py "${HTML_FILE}" "${CSV_FILE}"`
    fi
done