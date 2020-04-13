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


def main(args):
    print('Downloding map...')
    download_map()

    print('Downloding PDF files...')
    download_pdf_files()


def download_map():
    url = URL_MAP
    headers = {'Content-Type': 'application/json; charset=UTF-8'}

    # TODO - error handling
    basename = get_map_filename()
    cache_file = Path('{}{}{}.txt'.format(ROOT_DIR, CACHE_MAP_DIR, basename))

    if (cache_file.is_file()):
        print('Cache file exists, skipping: {}'.format(basename))
        return
    
    print('New file does not exist, retrieving from json')
    text = requests.post(url, headers=headers).text
    cache_file.write_bytes(text.encode())


def get_map_filename():
    content = request_url_get(URL_MAP)

    match = re.search(r'Cierre con corte a las (\d+:\d+) hrs, (\d+) de (\w+) de (\d+)', str(content))
    if match:
        time_file = match[1].replace(':', '_')
        month = es_months().get(match[3].lower(), match[3].lower())
        date_file = '{}{}{}'.format(match[4], month, match[2])
        
        return '{}_{}'.format(date_file, time_file)

    print('Could not get cut off date from map')
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
    return re.sub('.*?(\d{4})[.-](\d{2})[.-](\d{2})', '\\1\\2/\\1\\2\\3', text)


def get_soup(contents):
    return BeautifulSoup(contents, 'html.parser')


if __name__ == '__main__':
    main(sys.argv[1:])
