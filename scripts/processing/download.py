# -*- coding: utf-8 -*-

import sys 

from _download_map import download_map
from _download_pdfs import download_pdfs
from _download_zip import download_zip

from helpers import *
from utils import *

def main(args):
    print('Downloding map...')
    download_map(URL_MAP, '/all/')

    print('Downloding map by population...')
    download_map(URL_T_MAP, '/tasas/')   

    print('Downloding map by active cases...')
    download_map(URL_A_MAP, '/active/')    

    print('Downloding PDF files...')
    download_pdfs(URL_PDFS)

    print('Downloding ZIP...')
    download_zip(URL_ZIP)


if __name__ == '__main__':
    main(sys.argv[1:])
