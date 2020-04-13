# coding=utf-8

import re
import pprint
import json
import pandas as pd
import sys
import os
import datetime
from pathlib import Path
from utils import *


#  git ls-tree -r --name-only HEAD | while read filename; do echo "$(git log -1 --format="%ad" -- $filename),$filename" >> "./cache/meta/files.txt"; done
#  
def main(args):
    df = pd.DataFrame(columns = ['File', 'Basename', 'Type', 'Subtype', 'Last_Modified']) 

    for elem in Path('./www/').rglob('*.csv'):
        # append new 
        df.loc[len(df)] = [
            str(elem).replace('www', ''),
            os.path.basename(elem).replace('.csv', ''),
            get_file_type(elem),
            get_file_subtype(elem),
            get_last_modified(elem)
        ]

    df['Date'] = [get_file_date(x) for x in df.File]
    df['Month'] = [get_file_month(x) for x in df.Date]
    df['State'] = [get_state(x) for x in df.File]
    df['State_Name'] = [get_state_from_iso(x) for x in df.State]

    df.to_csv('./www/meta/files.csv', index=False)
    df.to_json('./www/meta/files.columns.json', orient="columns", indent=2)
    df.to_json('./www/meta/files.index.json', orient="index", indent=2)
    df.to_json('./www/meta/files.values.json', orient="values", indent=2)

    # by group
    df.groupby('Type').apply(lambda x: x.to_json('./www/meta/{}.json'.format(x.Type.iloc[0]), orient='records'))


def get_file_type(elem):
    regex = re.compile(r'www\/([\w-]+)\/')

    return re.search(regex, str(elem))[1].replace('-', '_')


def get_file_subtype(elem):
    regex = re.compile(r'www\/[\w-]+\/([\w-]+)[\/.]')

    matches = re.search(regex, str(elem))
    if matches:
        return "{}".format(matches[1])

    return None


def get_last_modified(elem):
    return datetime.datetime.utcfromtimestamp(elem.stat().st_mtime).strftime('%Y-%m-%d %H:%M:%S')


def get_file_date(column):
    regex = re.compile(r'[\/_](\d{4})(\d{2})(\d{2}).csv')

    matches = re.search(regex, column)
    if matches:
        return "{}-{}-{}".format(matches[1], matches[2], matches[3]) 

    return None


def get_file_month(text):
    if text:
        regex = re.compile(r'\d{4}-(\d{2})-\d{2}')

        matches = re.search(regex, text)
        if matches:
            return "{}".format(matches[1]) 

    return None


def get_state(column):
    regex = re.compile(r'\/estatal_(\w{3}).csv')

    matches = re.search(regex, column)
    if matches:
        return "{}".format(matches[1]) 

    return None


def get_state_from_iso(iso):
    # see https://en.wikipedia.org/wiki/Template:Mexico_State-Abbreviation_Codes
    dictionary = {
        'AGU':'Aguascalientes',
        'BCN':'Baja California',
        'BCS':'Baja California Sur',
        'CAM':'Campeche',
        'CHP':'Chiapas',
        'CHH':'Chihuahua',
        'COA':'Coahuila de Zaragoza',
        'COL':'Colima',
        'CMX':'Ciudad de México',
        'DUR':'Durango',
        'GUA':'Guanajuato',
        'GRO':'Guerrero',
        'HID':'Hidalgo',
        'JAL':'Jalisco',
        'MEX':'Estado de México',
        'MIC':'Michoacán',
        'MOR':'Morelos',
        'NAY':'Nayarit',
        'NLE':'Nuevo León',
        'OAX':'Oaxaca',
        'PUE':'Puebla',
        'QUE':'Querétaro',
        'ROO':'Quintana Roo',
        'SLP':'San Luis Potosí',
        'SIN':'Sinaloa',
        'SON':'Sonora',
        'TAB':'Tabasco',
        'TAM':'Tamaulipas',
        'TLA':'Tlaxcala',
        'VER':'Veracruz',
        'YUC':'Yucatán',
        'ZAC':'Zacatecas'
    }

    if iso:
        return dictionary.get(iso.upper(), iso)

    return None

#----------------------------------------------------------------

if __name__ == '__main__':
    main(sys.argv[1:])
