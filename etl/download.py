# -*- coding: utf-8 -*-

import sys 

from _download_map import download_map
from _download_pdf import download_pdf
from _download_zip import download_zip

from helpers import logger

def main(args):

    file_type, source, destination = parse_args(args)

    if file_type == 'map':
        logger.info('Downloding map {}: '.format(source))
        download_map(source, destination)   
    elif file_type == 'zip':
        logger.info('Downloding ZIP...')
        download_zip(source, destination)
    elif file_type == 'pdf':
        logger.info('Downloding pdf...')
        download_pdf(source, destination)


def parse_args(argv):
    if len(argv) < 3:
        logger.info('usage: download.py <type> <source> <states> <destination>')
        logger.info('example: python download.py "map/pdf/zip" "https://source.com" "mydest.txt"')
        exit()

    return argv[0], argv[1], argv[2]


if __name__ == '__main__':
    main(sys.argv[1:])
