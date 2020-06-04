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

    # parser.add_argument('-options', action='append', dest='options',
    #                     default=[],
    #                     help='Add options to the list',
    #                     )
                        
    args = parser.parse_args()

    return args


if __name__ == '__main__':
    main()
