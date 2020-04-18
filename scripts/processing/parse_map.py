import hashlib
import json
import pandas as pd
import os
import re
import sys

from helpers import *
from utils import *

# -------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------

# TODO: Improve, error handling, testing & documentation

def main(args):
    source, destination = parse_args(args)
    
    contents = load_from_file(source)

    df, date = create_dataframe_from_json(contents)

    print(df)
    df = append_additional_columns(df, date)

    df.to_csv(destination, index = False)

    
def parse_args(argv):
    if len(argv) < 2:
        print('usage: parse.py <source> <destination>')
        print('example: python parse_map.py "20200411_14_30.txt" "federal_20200414.csv"')
        exit()

    # TODO: improve & error handling & testing

    return argv[0], argv[1]

    
def load_from_file(file):
    with open(file, 'r') as f:
        return json.loads(json.load(f)['d'])


def create_dataframe_from_json(text):
    first_row = text[0]

    if len(first_row) not in [9, 10]:
        error = 'Could not parse map... length of text not valid {}'.format(first_row)
        raise Exception(error)

    columns = [
        'D1', 'Estado', 'D2', 'D3', 'Positivos', 'Negativos', 'Sospechosos', 'Defunciones', 'Time'
    ]

    if len(first_row) == 10:
        columns.append('Date')

    match = re.search(r'(\d+) de (\w+) de (\d+)', str(first_row[-1:]))
    
    if match:
        month = es_months().get(match[2].lower(), match[2].lower())
        date = '{}-{}-{}'.format(match[3], month, match[1])
    else:
        raise Exception('No Date Found: {}'.format(first_row))

    df = pd.DataFrame(text, columns=columns) 

    df = df[['Estado', 'Positivos', 'Negativos', 'Sospechosos', 'Defunciones']]
    
    return df, date


def append_additional_columns(df, date):
    df['Estado'] = df['Estado'].apply(lambda x: get_iso_from_state(strip_accents(str(x).upper())))
    df['Fecha'] = date
    df['Inconsistencias'] = None

    df = df[['Fecha', 'Estado', 'Positivos', 'Sospechosos', 'Negativos', 'Defunciones', 'Inconsistencias']]
    
    # dropping summary line!
    df = df.drop(df[df['Estado'].str.contains('NACIONAL', regex=True, na=False)].index)

    return df


if __name__ == "__main__":
    main(sys.argv[1:])
