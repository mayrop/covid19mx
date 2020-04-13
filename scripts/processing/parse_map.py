import hashlib
import json
import pandas as pd
import os
import re
import sys
from helpers import get_iso_from_state, strip_accents
from datetime import date

from utils import *

# -------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------

# TODO: Improve, error handling, testing & documentation

def main(args):
    source, destination = parse_args(args)
    
    contents = load_from_file(source)

    df = create_dataframe_from_json(contents)
    df = append_additional_columns(df)

    df.to_csv(destination, index = False)

    
def parse_args(argv):
    if len(argv) < 2:
        print('usage: parse.py <source> <destination>')
        print('example: python parse_map.py "20200411_14_30.txt" "federal_2020041.csv"')
        exit()

    # TODO: improve & error handling & testing

    return argv[0], argv[1]

    
def load_from_file(file):
    with open(file, 'r') as f:
        return json.loads(json.load(f)['d'])


def create_dataframe_from_json(text):
    df = pd.DataFrame(text, columns =[
        'D1', 'Estado', 'D2', 'D3', 'Positivos', 'Negativos', 'Sospechosos', 'Defunciones'
    ]) 
    df = df[['Estado', 'Positivos', 'Negativos', 'Sospechosos', 'Defunciones']]
    
    return df


def append_additional_columns(df):
    df['Estado'] = df['Estado'].apply(lambda x: get_iso_from_state(strip_accents(str(x).upper())))
    df['Fecha'] = date.today().strftime("%Y-%m-%d")
    df['Inconsistencias'] = None

    df = df[['Estado', 'Fecha', 'Positivos', 'Sospechosos', 'Negativos', 'Defunciones', 'Inconsistencias']]
    
    return df


if __name__ == "__main__":
    main(sys.argv[1:])
