#!/bin/bash

DIRECTORY=$(cd `dirname $0` && pwd)
ROOT=$(dirname $DIRECTORY)
ROOT=$(dirname $ROOT)

DATA_DIRECTORY="www"
ROOT_DATA_DIRECTORY="${ROOT}/${DATA_DIRECTORY}/tablas-diarias"

cd $ROOT

python ./scripts/processing/download.py

# processing each pdf file
for FILE in `find $ROOT_DATA_DIRECTORY -name "*.pdf" | grep -E "sospechosos|positivos" | grep -v "c.pdf"`
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
    ./scripts/processing/compress.sh -s $ORIG_FILE -o 1
done
