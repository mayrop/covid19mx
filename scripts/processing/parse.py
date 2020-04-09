import re
import datetime
import csv
import sys 
import codecs
import pandas as pd

from bs4 import BeautifulSoup
from helpers import *

def main(args):
    source, destination = parse_args(args)

    #source = '../../www/tablas-diarias/sospechosos/202003/20200324.html'
    #destination = '../../www/tablas-diarias/sospechosos/202003/20200324.csv'
    
    soup = get_soup(source)
    lines = get_lines(soup)
    df = get_df_from_lines(lines)
    df = normalize_df(df)

    # adding df
    df.to_csv(destination, index = False)


def parse_args(argv):
    if len(argv) < 2:
        print('usage: parse.py <source> <destination>')
        exit()

    # TODO: improve & error handling & testing

    return argv[0], argv[1]


def get_soup(source):
    file = codecs.open(source, 'r')
    soup = BeautifulSoup(file.read(), 'html.parser')
    file.close()

    return soup    


def get_lines(soup):
    ids = re.findall(r'id\s*=\s*\"(pf\w+)\"', str(soup.contents))

    lines = {}
    for div_id in ids:
        pdf_html = soup.find(id=str(div_id))
        divs_html = pdf_html.find_all('div', class_='c')

        for div in divs_html: 
            # TODO: error handling
            row_id = str(div_id) + '_' + div['class'][2]
            
            if row_id not in lines:
                lines[row_id] = list()

            lines[row_id].append(str(div.get_text()).strip())

    return lines 


def get_df_from_lines(lines):
    drop = []

    for key, line in lines.items():
        if len(line) == 1:
            drop.append(key)
            
    for key in drop:
        lines.pop(key)

    return pd.DataFrame.from_records(lines).T    


#---------------------------------------------------------------- 

def normalize_text(text):
    return strip_accents(text.upper())


def normalize_origin(text):
    text = normalize_text(text)
    text = convert_na(text)
        
    text = re.sub(r'TRIESTE$', 'ITALIA', text)
    text = re.sub(r'REPUBLICA CHECA Y REPUBLICA ESLOVACA$', 'REPUBLICA CHECA', text)
    text = re.sub(r'REPUBLICA DE COSTA RICA$', 'COSTA RICA', text)
    text = re.sub(r'REPUBLICA DE HONDURAS$', 'HONDURAS', text)
    text = re.sub(r'GRAN BRETAÑA \(REINO UNIDO\)$', 'GRAN BRETAÑA', text)
    text = re.sub(r'REPUBLICA$', 'REPUBLICA CHECA', text)
    text = re.sub(r'ARABIA$', 'ARABIA SAUDITA', text)
    text = re.sub(r'ESTADOS UNIDOS DE AMERICA$', 'ESTADOS UNIDOS', text)
    text = re.sub(r'ESTADOS$', 'ESTADOS UNIDOS', text)
    text = re.sub(r'EMIRATOS$', 'EMIRATOS ARABES', text)
    text = re.sub(r'GRAN$', 'GRAN BRETAÑA', text)
    text = re.sub(r'OTRO$', 'CONTACTO', text)
    text = re.sub(r'MEX$', 'CONTACTO', text)
    text = re.sub(r'EMIRATOS ARABES UNIDOS$', 'EMIRATOS ARABES', text) 
    
    return text


def normalize_sex(text):
    if text == 'MASCULINO':
        return 'M'

    if text == 'FEMENINO':
        return 'F'  
    
    return text



def normalize_date(text):
    text = convert_na(text)
    return re.sub('(\d+)/(\d+)/(\d+)', '\\3-\\2-\\1', text)


def normalize_df(df):
    # assign correct headers
    df.columns = get_col_names(df)

    # drop heading line!
    df = df.drop(df[df['Caso'].str.contains('Caso', regex=True, na=False)].index)

    # adding normalized columns    
    df['Estado_Normalizado'] = [get_iso_from_state(normalize_text(x).replace("*", "")) for x in df.Estado]

    if 'Localidad' in df.columns:
        df['Localidad_Normalizado'] = [normalize_text(x) for x in df.Localidad]
    else:
        df['Localidad'] = ''
        df['Localidad_Normalizado'] = ''

    df['Sexo_Normalizado'] = [normalize_sex(x) for x in df.Sexo]
    df['Fecha_Sintomas_Normalizado'] = [normalize_date(get_fixed_date(x)) for x in df.Fecha_Sintomas]
    df['Situacion_Normalizado'] = [normalize_text(x) for x in df.Situacion]
    df['Fecha_Sintomas_Corregido'] = [is_date_in_excel_format(x) for x in df.Fecha_Sintomas]

    if 'Fecha_Llegada' in df.columns:
        df['Fecha_Llegada_Normalizado'] = [normalize_date(get_fixed_date(x)) for x in df.Fecha_Llegada]
    else:
        df['Fecha_Llegada'] = ''
        df['Fecha_Llegada_Normalizado'] = ''
        
    if 'Procedencia' in df.columns:
        df['Procedencia_Normalizado'] = [normalize_origin(x) for x in df.Procedencia]
    else:
        df['Procedencia'] = ''
        df['Procedencia_Normalizado'] = ''

    df = df[[
        'Caso', 'Estado', 'Localidad', 'Sexo', 'Edad', 'Fecha_Sintomas',
        'Situacion', 'Procedencia', 'Fecha_Llegada', 
        # then normalized in same order of appereance
        'Estado_Normalizado', 'Localidad_Normalizado', 'Sexo_Normalizado',
        'Fecha_Sintomas_Normalizado', 'Fecha_Sintomas_Corregido',
        'Situacion_Normalizado', 'Procedencia_Normalizado', 'Fecha_Llegada_Normalizado'
    ]]

    casts = {'Caso': 'int32'}
    df = df.astype(casts)

    #np.unique(df.Fecha_Sintomas_Corregido, return_counts=True)
    return(df.sort_values(by=['Caso']))


#----------------------------------------------------------------

def get_col_names(df):
    # normal pdfs
    row = df[
        (df[0].apply(regex_filter, regex='Caso')) &
        (df[1].apply(regex_filter, regex='Estado')) &
        (df[2].apply(regex_filter, regex='Sexo')) &
        (df[3].apply(regex_filter, regex='Edad')) &
        (df[4].apply(regex_filter, regex='Inicio')) &
        (df[5].apply(regex_filter, regex='Identificación'))
    ]
        
    if (len(row) == 1):
        headers =  [
            'Caso', 'Estado', 'Sexo', 'Edad',  'Fecha_Sintomas',  'Situacion'
        ]
        
        # as per april 6
        if len(df.columns) == 8:
            headers.append('Procedencia')
            headers.append('Fecha_Llegada')
            
        # as per april 7
        if len(df.columns) == 7:
            headers.append('Procedencia')
            
        return headers
    
    # some pdfs have localities :/
    row = df[
        (df[0].apply(regex_filter, regex='Caso')) &
        (df[1].apply(regex_filter, regex='Estado')) &
        (df[2].apply(regex_filter, regex='Localidad')) &
        (df[3].apply(regex_filter, regex='Sexo')) &
        (df[4].apply(regex_filter, regex='Edad')) &
        (df[5].apply(regex_filter, regex='Inicio')) &
        (df[6].apply(regex_filter, regex='Identificación')) &
        (df[7].apply(regex_filter, regex='Procedencia')) &
        (df[8].apply(regex_filter, regex='Llegada'))
    ]
        
    if (len(row) == 1):
        return [
            'Caso', 'Estado', 'Localidad', 'Sexo', 'Edad',  
            'Fecha_Sintomas',  'Situacion', 'Procedencia',
            'Fecha_Llegada'
        ]    
        
    print(df[df[0].str.contains('Caso', regex=True, na=False)])
    print('Check headers!')
    exit()

#----------------------------------------------------------------

if __name__ == '__main__':
    main(sys.argv[1:])
