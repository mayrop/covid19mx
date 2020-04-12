import re
import sys 
from helpers import *


#---------------------------------------------------------------- 

def normalize_df(df):
    # assign correct headers
    df.columns = get_col_names(df, source)
 
    # drop heading line!
    df = df.drop(df[df['Caso'].str.contains('Caso', regex=True, na=False)].index)
    df = df.astype({'Caso': 'int32'})
        
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

    df = df.astype({'Caso': 'int32'})

    #np.unique(df.Fecha_Sintomas_Corregido, return_counts=True)
    return(df.sort_values(by=['Caso']))


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
