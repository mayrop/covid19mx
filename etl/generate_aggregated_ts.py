import os
import re
import sys
import pandas as pd
from pathlib import Path
from utils import *


def main(args):
    suffix = parse_args(args)

    source = '{}/www/series-de-tiempo/federal{}/'.format(ROOT_DIR, suffix)
    source_st = '{}/www/series-de-tiempo/estatal{}/'.format(ROOT_DIR, suffix)
    totals_bak_source = '{}/scripts/analysis/bak/totales.csv'.format(ROOT_DIR)
    destination_main = '{}/www/series-de-tiempo/agregados/federal{}.csv'.format(ROOT_DIR, suffix)
    destination_aggregated = '{}/www/series-de-tiempo/agregados/totales{}.csv'.format(ROOT_DIR, suffix)

    # generating main file from individual files
    generate_main_file(source, destination_main)

    # now continue to read...
    df = pd.read_csv(destination_main)
    df = fix_na_for_positives(df)

    print("Generating federal")
    generate_all_federal(df, source)

    print("Generating state")
    generate_all_state(df, source_st)

    # generating this one only if it's for UM
    if not suffix:
        generate_aggregated(df, pd.read_csv(totals_bak_source), destination_aggregated)


def create_file_dir(file):
    outdir = os.path.dirname(file)

    if not os.path.exists(outdir): 
        output_dir = Path(outdir)

        print("Creating folder: {}".format(outdir))
        output_dir.mkdir(parents=True, exist_ok=True)


def load_all_files(source):
    my_dict = {} 
    
    print("Loading files from: {}".format(source)) 
    
    for elem in Path(source).rglob('*.csv'):
        index = re.sub(r".*/(federal_\d+).csv", "\\1", str(elem))
        df = pd.read_csv(elem, encoding = "ISO-8859-1", engine='python') 
        df = df[df.columns[~df.columns.str.endswith('_Delta')]]
        
        my_dict[index] = df

    return my_dict


def generate_main_file(source, dest):
    all_files = load_all_files(source)

    df = pd.concat([v for k, v in all_files.items()])

    df = df.sort_values(by=['Fecha', 'Estado'])
    
    df = add_delta_columns_by_date_and_state(df)

    df = df[cols_to_pick()]

    df = change_types(df)

    df = df.reset_index()

    create_file_dir(dest)
    df.to_csv(dest, index=False)
    
    return df
    

def generate_aggregated(df, bak, dest):
    totals = generate_totals(df).merge(bak, on='Fecha', how='left')
    totals['Sospechosos'] = totals['Sospechosos'].fillna(0)
    totals['Negativos'] = totals['Negativos'].fillna(0)
    
    totals.loc[totals['Sospechosos'] == 0, 'Sospechosos'] = totals.loc[totals['Sospechosos'] == 0, 'S']
    totals.loc[totals['Negativos'] == 0, 'Negativos'] = totals.loc[totals['Negativos'] == 0, 'N']

    totals = totals.drop(['S', 'N'], axis=1)
        
    totals = add_delta_columns_by_date(totals)
    totals = totals[cols_to_pick()]
    totals = change_types(totals)
    totals = totals.reset_index()
    
    create_file_dir(dest)
    totals.to_csv(dest, index=False)
    
    return totals


def generate_all_federal(df, dest):
    grouped = df.groupby('Fecha')

    for name, group in grouped:

        date_file = re.sub(r'-', '', name)
        month = re.sub(r'(\d{4})(\d{2})(\d{2})', '\\1\\2', date_file)
        
        file_name = '{}/{}/federal_{}.csv'.format(dest, month, date_file)
        group = change_types(group)

        create_file_dir(file_name)
        group.to_csv(file_name, index=False)

        
def generate_all_state(df, dest):
    grouped = df.groupby('Estado')

    for name, group in grouped:
        file_name = '{}/estatal_{}.csv'.format(dest, name.lower())

        group = change_types(group)

        create_file_dir(file_name)
        group.to_csv(file_name, index=False)


def generate_totals(df):
    grouped = df.groupby('Fecha')
    grouped_df = {}

    for date, group in grouped:
        my_df = {}
        my_df['Positivos'] = sum(group['Positivos'])
        my_df['Sospechosos'] = sum(group['Sospechosos'])
        my_df['Negativos'] = sum(group['Negativos'])
        my_df['Defunciones_Positivos'] = sum(group['Defunciones_Positivos'])
        my_df['Defunciones_Sospechosos'] = sum(group['Defunciones_Sospechosos'])
        my_df['Defunciones_Negativos'] = sum(group['Defunciones_Negativos'])
        my_df['Positivos_Sintomas_14_Dias'] = sum(group['Positivos_Sintomas_14_Dias'])
        my_df['Sospechosos_Sintomas_14_Dias'] = sum(group['Sospechosos_Sintomas_14_Dias'])
        my_df['Negativos_Sintomas_14_Dias'] = sum(group['Negativos_Sintomas_14_Dias'])
        my_df['Positivos_Sintomas_7_Dias'] = sum(group['Positivos_Sintomas_7_Dias'])
        my_df['Sospechosos_Sintomas_7_Dias'] = sum(group['Sospechosos_Sintomas_7_Dias'])    
        my_df['Negativos_Sintomas_7_Dias'] = sum(group['Negativos_Sintomas_7_Dias']) 

        grouped_df[date] = my_df
        
    new_df = pd.DataFrame.from_dict(grouped_df).T.reset_index()

    return new_df.rename(columns={'index': 'Fecha'})


def add_delta_columns_by_date_and_state(df):
    df = df.set_index(['Fecha','Estado'])
    shifted = df.groupby(level='Estado').shift(+1)
    
    # join the shifted df
    df = df.join(shifted.rename(columns=lambda x: x + '_Lag'))
    
    return add_delta_columns(df)


def add_delta_columns_by_date(df):
    df = df.set_index(['Fecha'])
    shifted = df.shift(+1)
    
    # join the shifted df
    df = df.join(shifted.rename(columns=lambda x: x + '_Lag'))
    
    return add_delta_columns(df)


def add_delta_columns(df):
    # calculate delta betwen days
    df['Positivos_Delta'] = df['Positivos'] - df['Positivos_Lag']
    df['Sospechosos_Delta'] = df['Sospechosos'] - df['Sospechosos_Lag']
    df['Negativos_Delta'] = df['Negativos'] - df['Negativos_Lag']
    df['Defunciones_Positivos_Delta'] = df['Defunciones_Positivos'] - df['Defunciones_Positivos_Lag']
    df['Defunciones_Sospechosos_Delta'] = df['Defunciones_Sospechosos'] - df['Defunciones_Sospechosos_Lag']
    df['Defunciones_Negativos_Delta'] = df['Defunciones_Negativos'] - df['Defunciones_Negativos_Lag']
    
    # fill NAs with 0 for all the delta columns
    df['Positivos_Delta'] = df['Positivos_Delta'].fillna(0)
    df['Sospechosos_Delta'] = df['Sospechosos_Delta'].fillna(0)
    df['Negativos_Delta'] = df['Negativos_Delta'].fillna(0)
    df['Defunciones_Positivos_Delta'] = df['Defunciones_Positivos_Delta'].fillna(0)
    df['Defunciones_Sospechosos_Delta'] = df['Defunciones_Sospechosos_Delta'].fillna(0)
    df['Defunciones_Negativos_Delta'] = df['Defunciones_Negativos_Delta'].fillna(0)
    
    return df


def change_types(df):

    # df.astype({'col1': 'int32'})
    regex = 'Positivos|Negativos|Defunciones|Sospechosos'

    cols = df.columns[df.columns.str.contains(regex, regex = True)].tolist()
    types = { col : 'Int64' for col in cols }

    return df.astype(types)


def cols_to_pick():
    return [
        'Positivos',
        'Positivos_Delta',
        'Sospechosos',
        'Sospechosos_Delta',
        'Negativos',
        'Negativos_Delta',
        'Defunciones_Positivos',
        'Defunciones_Positivos_Delta',
        'Defunciones_Sospechosos',
        'Defunciones_Sospechosos_Delta',
        'Defunciones_Negativos',
        'Defunciones_Negativos_Delta',
        'Positivos_Sintomas_14_Dias',
        'Sospechosos_Sintomas_14_Dias',
        'Negativos_Sintomas_14_Dias',
        'Positivos_Sintomas_7_Dias',
        'Sospechosos_Sintomas_7_Dias',
        'Negativos_Sintomas_7_Dias'
    ]


def fix_na_for_positives(df):
    df['Positivos'] = df['Positivos'].fillna(0)
    df['Defunciones_Positivos'] = df['Defunciones_Positivos'].fillna(0)
    
    return df


def parse_args(argv):
    if len(argv) > 1:
        print('usage: generate_aggregated_ts.py <suffix>')
        print('example: python generate_aggregated_ts.py "_res"')
        exit()

    # TODO: improve & error handling & testing
    if len(argv) == 1:
        return argv[0]

    return ''



#----------------------------------------------------------------

if __name__ == '__main__':
    main(sys.argv[1:])
