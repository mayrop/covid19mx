# -*- coding: utf-8 -*-

import re
import csv
import sys 
import os
import codecs
import pandas as pd
import requests
from pathlib import Path
from datetime import date
        
from bs4 import BeautifulSoup
from helpers import *
from utils import *


def main(args):
    download_pdf_files()
    download_map()


def download_map()
            
    return request_url(
        'https://ncov.sinave.gob.mx/Mapa.aspx/Grafica22',
        '{}/cache/mapa/{}'.format(ROOT_DIR, date.today().strftime("%Y%m%d"))
    )


def download_pdf_files():
    domain = 'https://www.gob.mx'
    path = '/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449'
    url = '{}{}'.format(domain, path)

    contents = request_url_get(
        url
    )

    soup = get_soup(contents)

    html = soup.find_all('div', {'class': 'table-responsive'})
    links = html[0].find_all('a')

    for link in links:
        url = '{}{}'.format(domain, link.get('href'))
        file = get_pdf_file(url)

        print('processing file {}'.format(str(file)))

        if file.is_file():
            print('file exists, skipping')
        else:
            print('file does not exist, downloading')
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
