# -*- coding: utf-8 -*-

import requests
import re
from pathlib import Path
from helpers import *
from utils import *

def download_map(url, suffix = ''):

    try:
        headers = {'Content-Type': 'application/json; charset=UTF-8'}

        text = requests.post(url, headers=headers).text
        basename = get_map_basename(text)

        cache = Path('{}{}{}{}.txt'.format(ROOT_DIR, CACHE_MAP_DIR, suffix, basename))

        if (cache.is_file()):
            print('Cache file exists, skipping: {}'.format(basename))
            return
        
        print('New file does not exist, retrieving from json')
        cache.write_bytes(text.encode())

    except BaseException as error:
        print('Map could not be downloaded')
        print('Error: {}'.format(error))


def get_map_basename(text):
    time = get_map_time(text)
    day = get_map_day(text)

    return '{}_{}'.format(day, time)


def get_map_time(text):
    match = re.search(r'Cierre con corte a las (\d+:\d+) hrs', str(text))

    if match:
        print('Time found in the map')
        time_file = match[1].replace(':', '_')
    else:
        print('Time not found in the map defaulting to: 14_00')
        time_file = '14_00'

    return time_file


def get_map_day(text):
    match = re.search(r'(\w+) de (\w+) de (\d+)', text)
    
    if match:
        month = es_months().get(match[2].lower(), match[2].lower())
        return '{}{}{}'.format(match[3], month, match[1])

    raise Exception('No date found in text')