#!/bin/bash

directory=$(cd `dirname $0` && pwd)
root=$(dirname $directory)
root=$(dirname $root)

data_dir="www"
root_zips_dir="${root}/${data_dir}/abiertos/todos/"
root_timeseries_dir="${root}/${data_dir}/series-de-tiempo/federal"
timeseries_script="${root}/scripts/processing/generate_timeseries.py"
states_file="${root}/www/otros/estados.csv"

echo "Moving to the root of the repo!"
cd $root

# processing each pdf file
echo "Processing ZIP files!"
for file in `find ${root_zips_dir} -name "*.zip"`
do
    echo "Unziping...${file}"
    basename="$(basename -- $file)"
    zip_dir="$(dirname $file)"

    cd $zip_dir

    target=$(echo ${basename} | sed -e "s/\.zip/\.csv/")
    timeseries_folder=$(echo ${target} | sed -E "s/([0-9]{6})[0-9]{2}\.csv/\1/")

    echo "Unzipping $file"
    unzip $file

    echo "Generating timeseries"
    python $timeseries_script $target "${root_timeseries_dir}/${timeseries_folder}/federal_${target}" $states_file ENTIDAD_UM
    python $timeseries_script $target "${root_timeseries_dir}_res/${timeseries_folder}/federal_${target}" $states_file ENTIDAD_RES

    echo "Removing csv file..."
    rm $target

    cd $root
done
