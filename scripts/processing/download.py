# -*- coding: utf-8 -*-

import re
import csv
import sys 
import os
import codecs
import pandas as pd
import requests
import hashlib

from pathlib import Path
from datetime import date
        
from bs4 import BeautifulSoup
from helpers import *
from utils import *
# http://187.191.75.115/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip

def main(args):
    print('Downloding map...')
    download_map(URL_MAP)

    print('Downloding map...')
    url = 'https://ncov.sinave.gob.mx/MapaTasas.aspx/Grafica22'
    download_map(url, 'tasas/')    

    print('Downloding PDF files...')
    download_pdf_files()

    print('Downloding ZIP...')
    download_zip()


def download_map(url, suffix = ''):
    url = URL_MAP
    headers = {'Content-Type': 'application/json; charset=UTF-8'}

    text = requests.post(url, headers=headers).text
    basename = get_map_basename(text)

    cache_file = Path('{}{}{}{}.txt'.format(ROOT_DIR, CACHE_MAP_DIR, suffix, basename))

    if (cache_file.is_file()):
        print('Cache file exists, skipping: {}'.format(basename))
        return
    
    print('New file does not exist, retrieving from json')
    cache_file.write_bytes(text.encode())


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

    print('No date found in text')
    exit()


def download_pdf_files():
    domain = 'https://www.gob.mx'

    contents = request_url_get(URL_PDFS)

    soup = get_soup(contents)

    html = soup.find_all('div', {'class': 'table-responsive'})

    if len(html) == 0:
        print('No links found...')
        return

    links = html[0].find_all('a')

    print('Found {} target files'.format(len(links)))

    for link in links:
        url = '{}{}'.format(domain, link.get('href'))
        file = get_pdf_file(url)

        print('Processing file {}'.format(str(file)))

        if file.is_file():
            print('File exists, skipping')
        else:
            print('File does not exist, downloading')
            response = requests.get(url)
            file.write_bytes(response.content)


def get_pdf_file(url):
    basename = os.path.basename(url)
    file_type = get_type(basename)
    file_name = get_basename(basename)

    path = '{}/www/tablas-diarias/{}/{}'.format(ROOT_DIR, file_type, file_name)

    return Path(path)


def get_type(text):
    if re.search(r'positivos', text, re.IGNORECASE):
        return 'positivos'

    if re.search(r'sospechosos', text, re.IGNORECASE):
        return 'sospechosos'

    if re.search(r'comunicado', text, re.IGNORECASE):
        return 'comunicado'

    return 'desconocido'


def get_basename(text):
    return re.sub(r'.*?(\d{4})[.-](\d{2})[.-](\d{2})', '\\1\\2/\\1\\2\\3', text)


def get_soup(contents):
    return BeautifulSoup(contents, 'html.parser')


def download_zip():
    contents = request_url_get(URL_ZIP)

    match = re.search(r'<p>(\d{2})/(\d{2})/(\d{2})</p>.*?<a href="([^"]+\.zip)">VER</a>', str(contents))
    
    if match:
        url = match[4]
        filepath = '{}20{}{}.zip'.format(match[3], match[2], match[1])

        print('Url to download from: {}'.format(url))
        print('Downloading zip! to {}'.format(filepath))
        request_zip(url, filepath)
        return

    print('no match found for zip!')
    exit()


if __name__ == '__main__':
    main(sys.argv[1:])
