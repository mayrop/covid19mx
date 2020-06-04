# -*- coding: utf-8 -*-

import requests
import re

from pathlib import Path
from helpers import logger, es_months, create_file_dir, interpolate_date

def download_map(source, destination):

    try:
        headers = {'Content-Type': 'application/json; charset=UTF-8'}

        text = requests.post(source, headers=headers).text
        map_path = get_map_path(destination, text)

        cache_file = Path('{}'.format(map_path))

        if (cache_file.is_file()):
            logger.debug('Cache file exists, skipping: {}'.format(map_path))
            return
        
        logger.info('New file does not exist, retrieving from json')
        
        create_file_dir(cache_file)
        cache_file.write_bytes(text.encode())

    except BaseException as error:
        logger.error('Error: Map could not be downloaded: {}'.format(error))


def get_map_path(destination, text):
    time = get_map_time(text)
    year, month, day = get_map_date(text)

    destination = interpolate_date(destination, year, month, day)
    
    return re.sub(r'{{time}}', time, destination)


def get_map_time(text):
    match = re.search(r'Cierre con corte a las (\d+:\d+)\s*hrs', str(text))

    if match:
        logger.debug('Time found in the map')
        time_file = match[1].replace(':', '_')
    else:
        logger.debug('Time not found in the map defaulting to: 14_00')
        time_file = '14_00'

    return time_file


def get_map_date(text):
    match = re.search(r'(\w+) de (\w+) de (\d+)', text)
    
    if match:
        month = es_months().get(match[2].lower(), match[2].lower())
        return match[3], month, match[1]

    raise Exception('No date found in text')