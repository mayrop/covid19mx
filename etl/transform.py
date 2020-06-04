# -*- coding: utf-8 -*-

import sys 
import argparse

from _transform_timeseries import transform_timeseries
from _transform_zip import transform_zip
from helpers import logger

def main():

    args = parse_args()

    if args.type == 'timeseries':
        logger.info('Transforming timeseries')
        transform_timeseries(args.source_file, 
                             args.destination_file, 
                             {'pattern': args.pattern})

    # > python ./etl/transform.py --type zip -s ./cache/zips//202004/20200430.zip -d ./www/abiertos/todos/{{Y}}{{m}}/{{Y}}{{m}}{{d}}.zip -p {{y}}{{m}}{{d}}COVID19MEXICO.csv
    elif args.type == 'zip':
        logger.info('Downloding ZIP')
        transform_zip(args.source_file, args.destination_file, {'pattern': args.pattern})

def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument('--type', choices=('zip', 'timeseries'), required=True)
    
    parser.add_argument('-s', action='store', dest='source_file',
                        help='Source ZIP file', required=True) 

    parser.add_argument('-d', action='store', dest='destination_file',
                        help='Destination for ZIP file', required=True)

    parser.add_argument('-p', action='store', dest='pattern',
                        help='The pattern for the source file', required=True)                                                

    args = parser.parse_args()

    return args


if __name__ == '__main__':
    main()
