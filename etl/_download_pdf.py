# -*- coding: utf-8 -*-

import re
import os
import requests

from pathlib import Path
        
from bs4 import BeautifulSoup
from helpers import logger, request_url_get, create_file_dir

def download_pdf(source, destination):
    try:
        contents = request_url_get(source)

        soup = BeautifulSoup(contents, 'html.parser')

        html = soup.find_all('div', {'class': 'table-responsive'})

        if len(html) == 0:
            logger.error('No links found...')
            return

        links = html[0].find_all('a')

        logger.debug('Found {} target files'.format(len(links)))

    except BaseException as error:
        logger.error('Exception found: {}'.format(error))


def get_pdf_file(url, destination):
    basename = os.path.basename(url)
    validate_type(basename)

    year, month, day = get_pdf_date(basename)

    destination = re.sub(r'{{Y}}', year, destination)
    destination = re.sub(r'{{m}}', month, destination)
    destination = re.sub(r'{{d}}', day, destination)
    
    return destination


def validate_type(text):
    if not re.search(r'comunicado', text, re.IGNORECASE):
        raise Exception('PDF type could not be identified... {}'.format(text))


def get_pdf_date(text):
    match = re.search(r'.*?(\d{4})[.-](\d{2})[.-](\d{2})', text)
    
    if match:
        return match[1], match[2], match[3]

    raise Exception('No date found in text {}'.format(text))


def process_links(links, destination):
    for link in links:
        try:
            url = '{}{}'.format('https://www.gob.mx', link.get('href'))
            pdf_path = get_pdf_file(url, destination)

            cache_file = Path('{}'.format(pdf_path))

            if cache_file.is_file():
                logger.debug('Cache file exists, skipping: {}'.format(pdf_path))
                continue

            logger.debug('PDF file does not exist, downloading')
            
            create_file_dir(cache_file)
            response = requests.get(url)
            cache_file.write_bytes(response.content)

        except BaseException as error:
            logger.error('Exception found for {}'.format(link.get('href')))
            logger.error('{}'.format(error))