# -*- coding: utf-8 -*-

import requests
import re
from pathlib import Path
from helpers import es_months, create_file_dir

def download_map(source, destination):

    try:
        headers = {'Content-Type': 'application/json; charset=UTF-8'}

        text = requests.post(source, headers=headers).text
        map_path = get_map_path(destination, text)

        cache_file = Path('{}'.format(map_path))

        if (cache_file.is_file()):
            print('>>Cache file exists, skipping: {}'.format(map_path))
            return
        
        print('>>New file does not exist, retrieving from json')
        create_file_dir(cache_file)
        cache_file.write_bytes(text.encode())

    except BaseException as error:
        print('Map could not be downloaded')
        print('Error: {}'.format(error))


def get_map_path(destination, text):
    time = get_map_time(text)
    year, month, day = get_map_date(text)

    destination = re.sub(r'{{Y}}', year, destination)
    destination = re.sub(r'{{m}}', month, destination)
    destination = re.sub(r'{{d}}', day, destination)
    
    return re.sub(r'{{time}}', time, destination)


def get_map_time(text):
    match = re.search(r'Cierre con corte a las (\d+:\d+)\s*hrs', str(text))

    if match:
        print('>>Time found in the map')
        time_file = match[1].replace(':', '_')
    else:
        print('>>Time not found in the map defaulting to: 14_00')
        time_file = '14_00'

    return time_file


def get_map_date(text):
    match = re.search(r'(\w+) de (\w+) de (\d+)', text)
    
    if match:
        month = es_months().get(match[2].lower(), match[2].lower())
        return match[3], month, match[1]

    raise Exception('No date found in text')