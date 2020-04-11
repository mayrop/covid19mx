import re
from bs4 import BeautifulSoup

def get_soup(source):
    file = codecs.open(source, 'r')
    soup = BeautifulSoup(file.read(), 'html.parser')
    file.close()

    return soup   


def parse_from_html(source):
    soup = get_soup(source)

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


def get_col_names_for_html(df):

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