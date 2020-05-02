import numpy as np
import os
import pandas as pd
import re
import sys

from datetime import datetime, timedelta

# ...

#  
def main(args):
    source, destination, states_file, field = parse_args(args)

    df = pd.read_csv(source, encoding = "ISO-8859-1", engine='python') 

    target_date_str = re.sub(r'(\d+)\.csv', '\\1', os.path.basename(source))
    target_date = datetime.strptime(target_date_str, '%Y%m%d')

    one_week_ago = target_date - timedelta(days=7)
    two_weeks_ago = target_date - timedelta(days=14)
    alive_date = '9999-99-99'

    print('evaluating for {}'.format(target_date))
    print('one week ago! {}'.format(one_week_ago))
    print('two week ago! {}'.format(two_weeks_ago))

    df = df.astype({'RESULTADO': 'int32'})

    df['FECHA_SINTOMAS'] = pd.to_datetime(df['FECHA_SINTOMAS'], format="%Y-%m-%d")

    df['RESULTADO_FACTOR'] = 'Desconocido'
    df.loc[df['RESULTADO'] == 1, 'RESULTADO_FACTOR'] = 'Positivos'
    df.loc[df['RESULTADO'] == 2, 'RESULTADO_FACTOR'] = 'Negativos'
    df.loc[df['RESULTADO'] == 3, 'RESULTADO_FACTOR'] = 'Sospechosos'

    df['IS_PATIENT'] = 1
    df['ALL_TIME'] = True
    df['LAST_7_DAYS'] = df.FECHA_SINTOMAS > one_week_ago
    df['LAST_14_DAYS'] = df.FECHA_SINTOMAS > two_weeks_ago
    df['HAS_DIED'] = df.FECHA_DEF != alive_date

    states = pd.read_csv(states_file)
    states = states.rename({
        'Clave': field, 
        'ISO_3': '{}_FACTOR'.format(field)
    }, axis=1)[[field, '{}_FACTOR'.format(field)]]

    df = df.merge(states, on=field, how='left')    

    main = get_main_series(df, field=field)
    main['Fecha'] = target_date.strftime('%Y-%m-%d')
    main = main[['Fecha', 'Estado', 'Positivos', 'Sospechosos', 'Negativos']]

    deaths = get_main_series(df[df['HAS_DIED'] == True], field=field, prefix='Defunciones_')
    
    last_14_days = get_main_series(df, field=field, value='LAST_14_DAYS', suffix='_Sintomas_14_Dias')
    last_7_days = get_main_series(df, field=field, value='LAST_7_DAYS', suffix='_Sintomas_7_Dias')

    summary_df = main.merge(deaths, on='Estado', how='left')
    summary_df = summary_df.merge(last_14_days, on='Estado', how='left')
    summary_df = summary_df.merge(last_7_days, on='Estado', how='left')

    summary_df.to_csv(destination, index=False)  


def get_main_series(df, field='ENTIDAD_UM', value='ALL_TIME', prefix='', suffix=''):
    index = '{}_FACTOR'.format(field)

    my_df = pd.pivot_table(
        df, 
        values=[value],  
        index=[index, 'RESULTADO_FACTOR'],
        columns=['IS_PATIENT'], aggfunc=np.sum
    ).unstack()

    my_df = modify_pivot_df(my_df, field)
    
    my_df = my_df.rename(
        columns={
            'Positivos': '{}Positivos{}'.format(prefix, suffix),
            'Sospechosos': '{}Sospechosos{}'.format(prefix, suffix),
            'Negativos': '{}Negativos{}'.format(prefix, suffix)
        })

    return my_df[['Estado', 
                  '{}Positivos{}'.format(prefix, suffix), 
                  '{}Sospechosos{}'.format(prefix, suffix), 
                  '{}Negativos{}'.format(prefix, suffix)]]


def modify_pivot_df(df, field='ENTIDAD_UM'):
    df.columns = df.columns.get_level_values(2)
    df = df.reset_index()
    df.index.name = None

    df['Sospechosos'].fillna(0, inplace=True)
    df['Negativos'].fillna(0, inplace=True)
    df['Positivos'].fillna(0, inplace=True)    
    df = df.astype({
        'Sospechosos': 'int32', 
        'Negativos': 'int32', 
        'Positivos': 'int32'
    })

    index = '{}_FACTOR'.format(field)

    df = df.rename(
        columns={
            index: 'Estado'
        })
    
    return df


def parse_args(argv):
    if len(argv) < 4:
        print('usage: generate_timeseries.py <source> <destination> <states> <field>')
        print('example: python generate_timeseries.py "20200414.csv" "federal_20200414.csv" "../../estados.csv" "ENTIDAD_UM"')
        exit()

    # TODO: improve & error handling & testing

    return argv[0], argv[1], argv[2], argv[3]



#----------------------------------------------------------------

if __name__ == '__main__':
    main(sys.argv[1:])
