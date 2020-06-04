import re
import requests
import sys

from pathlib import Path
from helpers import logger, es_months, request_url_get, create_file_dir, interpolate_date

# http://187.191.75.115/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip
def download_zip(source, destination):
    try:
        text = request_url_get(source)
        zip_path, zip_url = get_zip_path_and_url(destination, text)

        cache_file = Path('{}'.format(zip_path))

        if cache_file.is_file():
            logger.debug('ZIP file exists. Skipping {}'.format(cache_file))
            return

        logger.debug('ZIP file does not exist, downloading...')
        request_zip(zip_url, cache_file)

    except BaseException as error:
        logger.error('ZIP could not be downloaded: {}'.format(error))
        sys.exit(1)


def get_zip_path_and_url(destination, text):
    regex = r'(\d{2})/(\d{2})/(\d{4})</td>.*?<a href="([^"]+\.zip)">VER</a>'
    match = re.search(regex, str(text))

    if not match:
        raise Exception('No match found for ZIP in text...')

    url = match[4]
    year, month, day = get_zip_date(match)

    destination = interpolate_date(destination, year, month, day)

    return destination, url    


def get_zip_date(match):
    month = es_months().get(match[2].lower(), match[2].lower())
    
    return match[3], month, match[1]


# https://stackoverflow.com/questions/9419162/download-returned-zip-file-from-url
def request_zip(url, save_path, chunk_size=128):
    create_file_dir(save_path)

    r = requests.get(url, stream=True)
    with open(save_path, 'wb') as fd:
        for chunk in r.iter_content(chunk_size=chunk_size):
            fd.write(chunk)

