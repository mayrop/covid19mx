# -*- coding: utf-8 -*-

import re
import os
import requests

from pathlib import Path
        
from bs4 import BeautifulSoup
from helpers import *
from utils import *

def download_pdfs(url):
    try:
        domain = 'https://www.gob.mx'

        contents = request_url_get(url)

        soup = get_soup(contents)

        html = soup.find_all('div', {'class': 'table-responsive'})

        if len(html) == 0:
            print('No links found...')
            return

        links = html[0].find_all('a')

        print('Found {} target files'.format(len(links)))

        for link in links:
            try:
                url = '{}{}'.format(domain, link.get('href'))
                file = get_pdf_file(url)

                print('Processing file {}'.format(str(file)))

                if file.is_file():
                    print('File exists, skipping')
                else:
                    print('File does not exist, downloading')
                    response = requests.get(url)
                    file.write_bytes(response.content)
            except BaseException as error:
                print('Exception found for {}'.format(link.get('href')))
                print('Error {}'.format(error))

    except BaseException as error:
        print('Exception found while trying to get pdfs {}'.format(error))


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

    raise Exception('PDF type could not be identified...')


def get_basename(text):
    return re.sub(r'.*?(\d{4})[.-](\d{2})[.-](\d{2})', '\\1\\2/\\1\\2\\3', text)


def get_soup(contents):
    return BeautifulSoup(contents, 'html.parser')

