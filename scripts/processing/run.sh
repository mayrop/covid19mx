#!/bin/bash

DIRECTORY=$(cd `dirname $0` && pwd)
ROOT=$(dirname $DIRECTORY)
ROOT=$(dirname $ROOT)

DATA_DIRECTORY="www"
ROOT_DATA_DIRECTORY="${ROOT}/${DATA_DIRECTORY}/tablas-diarias"

cd $ROOT

python ./scripts/processing/download.py
find cache/mapa/ -iname "*.txt"  -mmin -60 -print | grep -v "tasas" | xargs -I{}  python ./scripts/processing/parse_map.py {} federal.csv
# mv federal.csv www/series-de-tiempo/federal/202004/federal_20200415.csv

# processing each pdf file
for FILE in `find $ROOT -maxdepth 1 -name "*.zip"`
do
    echo "Unziping...${FILE}"
    BASENAME="$(basename -- $FILE)"
    DEST=$(echo ${FILE} | sed -e "s/\.zip//")
    CSV=$(echo ${BASENAME} | sed -e "s/\.zip/\.csv/")
    unzip $FILE
    mv $FILE "${FILE}.bak"

    mkdir -p zip
    rm -rfv zip/*
    mv *.csv $CSV

    zip -9 -r $FILE $CSV
done

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
for ORIG_FILE in `find . -iname "*.pdf" -mmin -60 -print | grep -v "comunicado"`
do
    ./scripts/processing/compress.sh -s $ORIG_FILE -o 1
done

python ./scripts/ci/generate_tree.py 