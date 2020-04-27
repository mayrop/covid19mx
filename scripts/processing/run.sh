#!/bin/bash

directory=$(cd `dirname $0` && pwd)
root=$(dirname $directory)
root=$(dirname $root)
readme_file="${root}/README.md"

data_dir="www"
root_maps_dir="${root}/cache/mapa/"
root_zips_dir="${root}/${data_dir}/abiertos/todos/"
root_cases_dir="${root}/${data_dir}/tablas-diarias/"
root_timeseries_dir="${root}/${data_dir}/series-de-tiempo/federal"
timeseries_script="${root}/scripts/processing/generate_timeseries.py"
states_file="${root}/www/otros/estados.csv"

echo "Moving to the root of the repo!"
cd $root

# echo "Downloading files ;)"
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
    timeseries_folder=$(echo ${target} | sed -E "s/([0-9]{6})[0-9]{2}\.csv/\1/")

    unzip $file

    if [ -f $source ]; then
        echo "Unzip file matches pattern, moving!"
        mv $source $target

        python $timeseries_script $target "${root_timeseries_dir}/${timeseries_folder}/federal_${target}" $states_file ENTIDAD_UM
        python $timeseries_script $target "${root_timeseries_dir}_res/${timeseries_folder}/federal_${target}" $states_file ENTIDAD_RES

        zip -9 -r $new_file $target

        echo "Removing temp files..."
        rm $file
        rm $target
    else
        echo "Source file does not match pattern, check!"
    fi

    cd $root
done

echo "Generating aggregated time series!"
python ./scripts/processing/generate_aggregated_ts.py 
python ./scripts/processing/generate_aggregated_ts.py "_res"

# generating the meta data files
echo "Generating meta data files!"
python ./scripts/processing/generate_meta_data.py 

echo "Updating the last update time for open data!"
last_update_od=$(find $root_zips_dir -iname \*.zip | sort -r | head -n 1 | sed -E "s@.*/([0-9]{4})([0-4]{2})([0-9]+).zip@\1-\2-\3@g")

# spanish updates
sed -ri -- "s@(<!-- UPDATE_ES:START.*>).*?(<!-- UPDATE_ES:END -->)@\1Última Actualización: ${last_update_od}\2@g" README.md
sed -ri -- "s@(<!-- UPDATE-OPENDATA_ES:START.*>).*?(<!-- UPDATE-OPENDATA_ES:END -->)@\1Última Actualización: ${last_update_od}\2@g" README.md
sed -ri -- "s@(<!-- UPDATE-TIMESERIES_ES:START.*>).*?(<!-- UPDATE-TIMESERIES_ES:END -->)@\1Última Actualización: ${last_update_od}\2@g" README.md

# english updates
sed -ri -- "s@(<!-- UPDATE_EN:START.*>).*?(<!-- UPDATE_EN:END -->)@\1Last Update: ${last_update_od}\2@g" README.md
sed -ri -- "s@(<!-- UPDATE-OPENDATA_EN:START.*>).*?(<!-- UPDATE-OPENDATA_EN:END -->)@\1Last Update: ${last_update_od}\2@g" README.md
sed -ri -- "s@(<!-- UPDATE-TIMESERIES_EN:START.*>).*?(<!-- UPDATE-TIMESERIES_EN:END -->)@\1Last Update: ${last_update_od}\2@g" README.md
