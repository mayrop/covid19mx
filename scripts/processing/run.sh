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

# # generating the meta data files
echo "Generating meta data files!"
python ./scripts/processing/generate_meta_data.py 
