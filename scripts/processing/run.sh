#!/bin/bash

directory=$(cd `dirname $0` && pwd)
root=$(dirname $directory)
root=$(dirname $root)

data_dir="www"
root_maps_dir="${root}/cache/mapa/"
root_zips_dir="${root}/${data_dir}/abiertos/todos/"
root_cases_dir="${root}/${data_dir}/tablas-diarias/"
root_timeseries_dir="${root}/${data_dir}/series-de-tiempo/federal/"

echo "Moving to the root of the repo!"
cd $root

echo "Downloading files ;)"
python ./scripts/processing/download.py

echo "Parsing maps if any!"
for file in `find $root_maps_dir -iname "*.txt" -mmin -10 -print | grep -v "tasas"`
do
    basename="$(basename -- $file)"
    target=$(echo ${basename} | sed -E "s/_[0-9]+_[0-9]+.txt/\.csv/")
    target=$(echo ${target} | sed -E "s/([0-9]{4}[0-9]{2})([0-9]{2})\./\1\/federal_\1\2\./")
    target="${root_timeseries_dir}${target}"

    if [ ! -f $target ]; then
        echo "Creating csv file from map ${target}"
        python ./scripts/processing/parse_map.py $file $target
    fi
done


# processing each pdf file
echo "Processing ZIP files!"
for file in `find $root_zips_dir -name "*orig.zip"`
do
    echo "Unziping...${file}"
    basename="$(basename -- $file)"
    zip_dir="$(dirname $file)"

    cd $zip_dir

    new_file=$(echo ${file} | sed -e "s/_orig//")
    target=$(echo ${basename} | sed -e "s/_orig\.zip/\.csv/")
    source=$(echo ${target} | sed -E "s/[0-9]{2}([0-9]{6})/\1COVID19MEXICO/")

    unzip $file

    if [ -f $source ]; then
        echo "Unzip file matches pattern, moving!"
        mv $source $target
        zip -9 -r $new_file $target

        echo "Removing temp files..."
        rm $file
        rm $target
    else
        echo "Source file does not match pattern, check!"
    fi

    cd $root
done

# # processing each pdf file
# echo "Processing positive and suspected PDF files"
# for file in `find $root_cases_dir -name "*.pdf" | grep -E "sospechosos|positivos" | grep -v "c.pdf"`
# do
#     basename="$(basename -- $file)"

#     txt_file=$(echo ${file} | sed -e "s/\.pdf/.txt/")
#     csv_file=$(echo ${file} | sed -e "s/\.pdf/.csv/")

#     # creating the txt file
#     if [ ! -f $txt_file ]; then
#         echo "Creating ${txt_file}"
#         pdftotext -layout $file $txt_file
#     fi

#     # processing the html file
#     if [ ! -f $csv_file ]; then
#         echo "Creating ${csv_file}"
#         echo "python ./scripts/processing/parse.py \"${txt_file}\" \"${csv_file}\""
#         python ./scripts/processing/parse_pdf.py "${txt_file}" "${csv_file}"
#     fi
# done

# # processing each pdf file
# echo "Compressing PDF files created in the last 10 mins!"
# for orig_file in `find . -iname "*.pdf" -mmin -10 -print | grep -v "comunicado"`
# do
#     ./scripts/processing/compress.sh -s $orig_file -o 1
# done

# # generating the meta data files
echo "Generating meta data files!"
python ./scripts/processing/generate_meta_data.py 