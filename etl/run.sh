#!/bin/bash

#Accept Arguments
while [[ $# -gt 1 ]]
do
key="$1"
case $key in
   -e|--extract)
   EXTRACT="$2"; shift;; 
esac
shift
done

# -- .- -.-- .-. --- .--. # .-- .- ... # .... . .-. .
# Functions
init_root() {
   directory=$(cd `dirname $0` && pwd)
   root=$(dirname $directory)
}

# see https://gist.github.com/pkuczynski/8665367
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
# -- .- -.-- .-. --- .--. # .-- .- ... # .... . .-. .

# Evaluate
init_root

log_file=${root}/log.txt
# see https://unix.stackexchange.com/questions/440426/how-to-prefix-any-output-in-a-bash-script

echo "" >> ${log_file}
echo "" >> ${log_file}
# exec > >(sed 's/^/$: /' | tee -a ${log_file} )
# exec 2> >(sed 's/^/$: (err) /' | tee -a ${log_file} >&2)

echo "-- .- -.-- .-. --- .--. # .-- .- ... # .... . .-. ."
echo $(date)
echo "-- .- -.-- .-. --- .--. # .-- .- ... # .... . .-. ."

# Read yaml file
eval $(parse_yaml "${root}/config.yml" "config_")

echo "Moving to the root of the repo!"
cd $root

# -- .- -.-- .-. --- .--. # .-- .- ... # .... . .-. .

# Downloading files
if [[ $EXTRACT ]]; then
   echo "Running Extraction Scripts"
   # loop through all configuration extract scripts and execute them
   for source_var in `compgen -A variable | grep "extract" | grep "source"`
   do
      source="${!source_var}"
      
      destination_var=$(echo ${source_var} | sed -e "s/source/output/")
      destination="${!destination_var}"

      handler_var=$(echo ${source_var} | sed -e "s/source/handler/")
      handler="${!handler_var}"

      data_type=$(echo ${source_var} | sed -e "s/config_data_extract_//" | cut -d'_' -f 1)

      echo "Running: ${data_type} $source ${root}${destination}"
      python ${root}/etl/download.py ${data_type} ${source} ${root}${destination}
   done
fi

# -- .- -.-- .-. --- .--. # .-- .- ... # .... . .-. .

echo "Running Transforming Scripts (ZIP)"
# loop through all configuration extract scripts and execute them
zips=$(compgen -A variable | grep "transform" | grep "zip")
source=$(echo ${zips} | tr " " "\n" | grep "source")
output=$(echo ${zips} | tr " " "\n" | grep "output")
pattern=$(echo ${zips} | tr " " "\n" | grep "pattern")

for file in `find ${root}${!source} -name "*.zip"`
do
   echo "Moving ZIP file..."
   python ${root}/etl/transform.py --type zip -s ${file} -d ${root}${!output} -p ${!pattern}
done
# echo ${!source}
# echo ${!pattern}
# echo ${!output}
# for source_var in ``
# do
#    source="${!source_var}"

#    echo $source_var | cut -d'_' -f 5
   
#    # destination_var=$(echo ${source_var} | sed -e "s/source/output/")
#    # destination="${!destination_var}"

#    # handler_var=$(echo ${source_var} | sed -e "s/source/handler/")
#    # handler="${!handler_var}"

#    # data_type=$(echo ${source_var} | sed -e "s/config_data_extract_//" | cut -d'_' -f 1)

#    # echo "Running: ${data_type} $source ${root}${destination}"
#    # python ${root}/etl/download.py ${data_type} ${source} ${root}${destination}
# done


# readme_file="${root}/README.md"

# data_dir="www"
# root_zips_dir="${root}/${data_dir}/abiertos/todos/"
# root_cases_dir="${root}/${data_dir}/tablas-diarias/"
# root_timeseries_dir="${root}/${data_dir}/series-de-tiempo/federal"
# timeseries_script="${root}/scripts/processing/generate_timeseries.py"
# states_file="${root}/www/otros/estados.csv"



# # processing each pdf file
# echo "Processing ZIP files!"
# for file in `find $root_zips_dir -name "*orig.zip"`
# do
#     echo "Unziping...${file}"
#     basename="$(basename -- $file)"
#     zip_dir="$(dirname $file)"

#     cd $zip_dir

#     new_file=$(echo ${file} | sed -e "s/_orig//")
#     target=$(echo ${basename} | sed -e "s/_orig\.zip/\.csv/")
#     source=$(echo ${target} | sed -E "s/[0-9]{2}([0-9]{6})/\1COVID19MEXICO/")
#     timeseries_folder=$(echo ${target} | sed -E "s/([0-9]{6})[0-9]{2}\.csv/\1/")

#     unzip $file

#     if [ -f $source ]; then
#         echo "Unzip file matches pattern, moving!"
#         mv $source $target

#         python $timeseries_script $target "${root_timeseries_dir}/${timeseries_folder}/federal_${target}" $states_file ENTIDAD_UM
#         python $timeseries_script $target "${root_timeseries_dir}_res/${timeseries_folder}/federal_${target}" $states_file ENTIDAD_RES

#         zip -9 -r $new_file $target

#         echo "Removing temp files..."
#         rm $file
#         rm $target
#     else
#         echo "Source file does not match pattern, check!"
#     fi

#     cd $root
# done

# echo "Generating aggregated time series!"
# python ./scripts/processing/generate_aggregated_ts.py 
# python ./scripts/processing/generate_aggregated_ts.py "_res"

# # generating the meta data files
# echo "Generating meta data files!"
# python ./scripts/processing/generate_meta_data.py 

# echo "Updating the last update time for open data!"
# last_update_od=$(find $root_zips_dir -iname \*.zip | sort -r | head -n 1 | sed -E "s@.*/([0-9]{4})([0-4]{2})([0-9]+).zip@\1-\2-\3@g")

# # spanish updates
# sed -ri -- "s@(<!-- UPDATE_ES:START.*>).*?(<!-- UPDATE_ES:END -->)@\1Última Actualización: ${last_update_od}\2@g" README.md
# sed -ri -- "s@(<!-- UPDATE-OPENDATA_ES:START.*>).*?(<!-- UPDATE-OPENDATA_ES:END -->)@\1Última Actualización: ${last_update_od}\2@g" README.md
# sed -ri -- "s@(<!-- UPDATE-TIMESERIES_ES:START.*>).*?(<!-- UPDATE-TIMESERIES_ES:END -->)@\1Última Actualización: ${last_update_od}\2@g" README.md

# # english updates
# sed -ri -- "s@(<!-- UPDATE_EN:START.*>).*?(<!-- UPDATE_EN:END -->)@\1Last Update: ${last_update_od}\2@g" README.md
# sed -ri -- "s@(<!-- UPDATE-OPENDATA_EN:START.*>).*?(<!-- UPDATE-OPENDATA_EN:END -->)@\1Last Update: ${last_update_od}\2@g" README.md
# sed -ri -- "s@(<!-- UPDATE-TIMESERIES_EN:START.*>).*?(<!-- UPDATE-TIMESERIES_EN:END -->)@\1Last Update: ${last_update_od}\2@g" README.md

# declare -p | diff "$tmpfile" -
