import hashlib
import json
import pandas as pd
import os
import re
import sys
from helpers import get_iso_from_state, strip_accents, request_url
from datetime import date

from utils import *

# -------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------

# TODO: Improve, error handling, testing & documentation

def main(args):
    destination = get_destination(parse_args(args))
    
    contents = load_contents()
    print(json.dumps(contents, indent=2, sort_keys=True))

    df = create_dataframe_from_json(contents)

    #df = append_total_row(df)
    df = append_additional_columns(df)

    df.to_csv(destination, index = False)

    
def parse_args(argv):
    if len(argv) == 1:
        argv[0]

    return None
                
    
def get_destination(dest = None):
    if dest:
        return dest
    
    today = date.today().strftime("%Y%m%d")

    return "federal_{}.csv".format(today)


def load_contents(file = None):
    return load_from_file(file)

    
def load_from_file(file):
    with open(file, 'r') as f:
        return json.loads(json.load(f)['d'])

    
def parse_json(text):
    contents = json.loads(text)
    contents = json.loads(contents['d'])

    return contents


def create_dataframe_from_json(text):
    df = pd.DataFrame(text, columns =[
        'D1', 'Estado', 'D2', 'D3', 'Positivos', 'Negativos', 'Sospechosos', 'Defunciones'
    ]) 
    df = df[['Estado', 'Positivos', 'Negativos', 'Sospechosos', 'Defunciones']]
    
    return df


def append_total_row(df):
    casts = {'Positivos': 'int32', 'Negativos': 'int32', 'Sospechosos': 'int32', 'Defunciones': 'int32'}
    df = df.astype(casts)

    total_row = pd.Series(['TOT'], index=['Estado'])
    total_row = total_row.append(df.sum(numeric_only=True))

    df = df.append(total_row, ignore_index=True)
    df = df.astype(casts)

    return df


def append_additional_columns(df):
    df['Estado'] = df['Estado'].apply(lambda x: get_iso_from_state(strip_accents(str(x).upper())))
    df['Inconsistencias'] = None
    df['Fecha'] = date.today().strftime("%Y-%m-%d")

    df = df[['Estado', 'Fecha', 'Positivos', 'Sospechosos', 'Negativos', 'Defunciones', 'Inconsistencias']]
    
    return df


if __name__ == "__main__":
    main(sys.argv[1:])
