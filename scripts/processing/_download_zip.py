import re
from helpers import *
from utils import *

# http://187.191.75.115/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip
def download_zip(url):
    contents = request_url_get(url)
    
    match = re.search(r'<p>(\d{2})/(\d{2})/(\d{2})</p>.*?<a href="([^"]+\.zip)">VER</a>', str(contents))

    if match:
        url = match[4]
        file = get_zip_file(match, '_orig')
        new_file = get_zip_file(match)

        if file.is_file() or new_file.is_file():
            print('ZIP file exists, skipping')
        else:
            print('ZIP file does not exist, downloading')
            request_zip(url, file)
        
        return

    print('No match found for zip!')


def get_zip_file(match, suffix=''):

    prefix = '{}/www/abiertos/todos/'.format(ROOT_DIR)
    year_month = '{}20{}'.format(match[3], match[2])
    path = '{}{}/{}{}{}.zip'.format(prefix, year_month, year_month, match[1], suffix)
    print('Path for ZIP: {}'.format(path))

    return Path(path)