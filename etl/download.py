# -*- coding: utf-8 -*-

import sys 

from _download_map import download_map
from _download_pdf import download_pdf
from _download_zip import download_zip


def main(args):

    file_type, source, destination = parse_args(args)

    if file_type == 'map':
        print('Downloding map {}: ', source)
        download_map(source, destination)   
    elif file_type == 'zip':
        print('Downloding ZIP...')
        download_zip(source, destination)
    elif file_type == 'pdf':
        print('Downloding pdf...')
        download_pdf(source, destination)


def parse_args(argv):
    if len(argv) < 3:
        print('usage: download.py <type> <source> <states> <destination>')
        print('example: python download.py "map/pdf/zip" "https://source.com" "mydest.txt"')
        exit()

    return argv[0], argv[1], argv[2]


if __name__ == '__main__':
    main(sys.argv[1:])
