import re
import requests

from pathlib import Path
from helpers import es_months, request_url_get, create_file_dir

# http://187.191.75.115/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip
def download_zip(source, destination):
    try:
        text = request_url_get(source)
        zip_path, zip_url = get_zip_path_and_url(destination, text)

        cache_file = Path('{}'.format(zip_path))

        if cache_file.is_file():
            print('ZIP file exists, skipping {}'.format(cache_file))
        else:
            print('ZIP file does not exist, downloading')
            request_zip(zip_url, cache_file)

    except BaseException as error:
        print('ZIP could not be downloaded')
        print('Error: {}'.format(error))


def get_zip_path_and_url(destination, text):
    regex = r'(\d{2})/(\d{2})/(\d{4})</td>.*?<a href="([^"]+\.zip)">VER</a>'
    match = re.search(regex, str(text))

    if match:
        url = match[4]
        year, month, day = get_zip_date(match)

        destination = re.sub(r'{{Y}}', year, destination)
        destination = re.sub(r'{{m}}', month, destination)
        destination = re.sub(r'{{d}}', day, destination)  

        return destination, url
    
    raise Exception('No match found for ZIP')


def get_zip_date(match):
    month = es_months().get(match[2].lower(), match[2].lower())
    
    return match[3], month, match[1]


# https://stackoverflow.com/questions/9419162/download-returned-zip-file-from-url
def request_zip(url, save_path, chunk_size=128):
    print(save_path)
    create_file_dir(save_path)

    r = requests.get(url, stream=True)
    with open(save_path, 'wb') as fd:
        for chunk in r.iter_content(chunk_size=chunk_size):
            fd.write(chunk)

