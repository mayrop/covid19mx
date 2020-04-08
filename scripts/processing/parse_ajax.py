import json
import pandas as pd
import re
import requests
import sys
from datetime import date

# TODO: improve & error handling

def main(args):
    destination = get_destination(parse_args(args))
    
    df = create_dataframe_from_json(load_contents())

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
    
    today = date.today().strftime("%Y-%m-%d")
    folder = date.today().strftime("%Y-%m")

    return "federal_{}.csv".format(folder, today)


def load_contents(file = None):
    if file:
        return load_from_file(file)
        
    return parse_json(load_from_url())

    
def load_from_file(file):
    with open(file, 'r') as f:
        return json.loads(json.load(f)['d'])

    
def parse_json(text):
    contents = json.loads(text)
    return json.loads(contents['d'])


def load_from_url(url = 'https://ncov.sinave.gob.mx/Mapa.aspx/Grafica22'):
    headers = {
        'Content-Type': 'application/json; charset=UTF-8'
    }

    response = requests.post(url, headers=headers)

    return response.text


def create_dataframe_from_json(text):
    df = pd.DataFrame(text, columns =[
        'D1', 'Estado', 'D2', 'D3', 'Positivos', 'Negativos', 'Sospechosos', 'Defunciones'
    ]) 
    df = df[['Estado','Positivos','Negativos', 'Sospechosos', 'Defunciones']]
    
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
    df['Estado'] = df['Estado'].apply(lambda x: get_iso(strip_accents(str(x).upper())))
    df['Inconsistencias'] = None
    df['Fecha'] = date.today().strftime("%Y-%m-%d")

    df = df[['Estado', 'Fecha', 'Positivos','Negativos', 'Sospechosos', 'Defunciones', 'Inconsistencias']]
    
    return df

    
def strip_accents(text):
    """
    could have done this:
    https://stackoverflow.com/questions/517923/what-is-the-best-way-to-remove-accents-in-a-python-unicode-string
    """
    
    rep = {
        "Á": "A", 
        "É": "E",
        "Í": "I",
        "Ó": "O",
        "Ú": "U"
    }

    rep = dict((re.escape(k), v) for k, v in rep.items()) 
    pattern = re.compile("|".join(rep.keys()))

    text = pattern.sub(lambda m: rep[re.escape(m.group(0))], text)

    return text


def get_iso(state):

    # see https://en.wikipedia.org/wiki/Template:Mexico_State-Abbreviation_Codes
    dictionary = {
        "AGUASCALIENTES": "AGU",
        "BAJA CALIFORNIA": "BCN",
        "BAJA CALIFORNIA SUR": "BCS",
        "CAMPECHE": "CAM",
        "CHIAPAS": "CHP",
        "CHIHUAHUA": "CHH",
        "COAHUILA": "COA",
        "COLIMA": "COL",
        "CIUDAD DE MEXICO": "CMX",
        "DURANGO": "DUR",
        "GUANAJUATO": "GUA",
        "GUERRERO": "GRO",
        "HIDALGO": "HID",
        "JALISCO": "JAL",
        "MEXICO": "MEX",
        "MICHOACAN": "MIC",
        "MORELOS": "MOR",
        "NAYARIT": "NAY",
        "NUEVO LEON": "NLE",
        "OAXACA": "OAX",
        "PUEBLA": "PUE",
        "QUERETARO": "QUE",
        "QUINTANA ROO": "ROO",
        "SAN LUIS POTOSI": "SLP",
        "SINALOA": "SIN",
        "SONORA": "SON",
        "TABASCO": "TAB",
        "TAMAULIPAS": "TAM",
        "TLAXCALA": "TLA",
        "VERACRUZ": "VER",
        "YUCATAN": "YUC",
        "ZACATECAS": "ZAC"
    }

    return dictionary.get(state, state)


if __name__ == "__main__":
    main(sys.argv[1:])
