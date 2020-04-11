import re
import datetime
import csv
import sys 
import codecs
import pandas as pd

from pprint import pprint
from helpers import *
from _parse_html import parse_from_html, get_col_names_for_html
from _parse_txt import parse_from_txt, get_col_names_for_txt
from _normalize import normalize_df

def main(args):
    source, destination = parse_args(args)

    #source = '../../www/tablas-diarias/sospechosos/202003/20200323.txt'
    #destination = '../../www/tablas-diarias/sospechosos/202003/20200324.csv'
    
    if '.html' in source:
        lines = parse_from_html(source)
    elif '.txt' in source:
        lines = parse_from_txt(source)
        
    # transform to data frame
    df = get_df_from_lines(lines)
    # assign correct headers
    df.columns = get_col_names(df, source)
 
    # drop heading line!
    df = df.drop(df[df['Caso'].str.contains('Caso', regex=True, na=False)].index)
    df = df.astype({'Caso': 'int32'})
    df = normalize_df(df)

    df.to_csv(destination, index = False)


def parse_args(argv):
    if len(argv) < 2:
        print('usage: parse.py <source> <destination>')
        exit()

    # TODO: improve & error handling & testing

    return argv[0], argv[1]


def get_df_from_lines(lines):
    drop = []

    for key, line in lines.items():
        if len(line) == 1:
            drop.append(key)
            
    for key in drop:
        lines.pop(key)

    return pd.DataFrame.from_records(lines).T


def get_colnames(df, source):
    if 'html' in source:
        get_col_names_for_html(df)

    return get_col_names_for_txt(df)


#----------------------------------------------------------------


#----------------------------------------------------------------

if __name__ == '__main__':
    main(sys.argv[1:])
