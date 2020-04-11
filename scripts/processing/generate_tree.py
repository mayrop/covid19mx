import re
from pathlib import Path
import pprint
import json

regex = re.compile(r'\w+\/([\w-]+)\/(\w+)\/(\d{4}(\d{2}))\/(\d{4}\d{2}(\d{2}))\.(\w+)')

my_dict = {
    'tablas': {},
    'series': {
        'federal': {},
        'estatal': {},
        'agregados': {}
    }
}


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

    return dictionary.get(iso.upper(), iso)

def get_my_month(string):
    dictionary = {
        "02": "Enero",
        "02": "Febrero",
        "03": "Marzo",
        "04": "Abril",
        "05": "Mayo",
        "06": "Junio",
        "07": "Julio"
    }

    return dictionary.get(string)

for elem in Path('./www/tablas-diarias/').rglob('*.*'):
    if not re.match(regex, str(elem)): 
        print('doesnt match {}'.format(str(elem)))
    else:
        matches = re.match(regex, str(elem))

        if 'html' in matches[7]:
            continue

        f_type = matches[2]
        f_folder = matches[3]
        f_path = matches[6]
        month = matches[4]
        day = matches[6]
        f_format = matches[7]

        if f_type not in my_dict['tablas'].keys(): 
            my_dict['tablas'][f_type] = {}
        
        if f_folder not in my_dict['tablas'][f_type].keys(): 
            my_dict['tablas'][f_type][f_folder] = {
                'fecha': '{}/2020'.format(month),
                # todo - remove hardcode
                'titulo': '{}, 2020'.format(get_my_month(month)),
                'elementos': {}
            }

        if f_path not in my_dict['tablas'][f_type][f_folder]['elementos'].keys():
            my_dict['tablas'][f_type][f_folder]['elementos'][f_path] = {
                # date format for mexico dd/mm/yyyy
                'fecha': '{}/{}/2020'.format(day, month)
            }

        my_dict['tablas'][f_type][f_folder]['elementos'][day][f_format] = str(elem).replace("www", "")

regex = re.compile(r'\w+\/[\w-]+\/federal\/(\d{4}(\d{2}))\/(.*?\d{4}\d{2}(\d{2}).csv)')


for elem in Path('./www/series-de-tiempo/agregados/').glob('*.csv'):
    my_dict['series']['agregados'][str(elem.name).replace(".csv", "")] = str(elem).replace("www", "")

for elem in Path('./www/series-de-tiempo/federal/').rglob('*.*'):
    if not re.match(regex, str(elem)): 
        print('doesnt match {}'.format(str(elem)))
    else:
        matches = re.match(regex, str(elem))

        f_folder = matches[1]
        f_path = matches[3]
        month = matches[2]
        day = matches[4]

        if f_folder not in my_dict['series']['federal'].keys(): 
            my_dict['series']['federal'][f_folder] = {
                'fecha': '{}/2020'.format(month),
                # todo - remove hardcode
                'titulo': '{}, 2020'.format(get_my_month(month)),
                'elementos': {}
            }

        my_dict['series']['federal'][f_folder]['elementos'][day] = {
            'fecha': '{}/{}/2020'.format(day, month),
            'path': str(elem).replace("www", "")
        }

regex = re.compile(r'\w+\/[\w-]+\/estatal\/estatal_(\w{3}).csv')        

for elem in Path('./www/series-de-tiempo/estatal/').rglob('*.*'):
    if not re.match(regex, str(elem)): 
        print('doesnt match {}'.format(str(elem)))
    else:
        matches = re.match(regex, str(elem))

        my_dict['series']['estatal'][matches[1]] = {
            'nombre': get_state_from_iso(matches[1]),
            'path': str(elem).replace("www", "")
        }


pprint.pprint(my_dict)

with open('www/files.json', 'w') as outfile:
    json.dump(my_dict, outfile)

with open('www/tables.json', 'w') as outfile:
    json.dump(my_dict['tablas'], outfile)

with open('www/series.json', 'w') as outfile:
    json.dump(my_dict['series'], outfile)    

# pprint.pprint(my_dict)


# def list_files(startpath, type):
#     startpath = '{}{}'.format(startpath, type)

#     thisdict = {}
#     for root, dirs, files in os.walk(startpath):
#         print(root)
#         print(dirs)
#         print(files)
#         # level = root.replace(startpath, '').count(os.sep)
#         # indent = ' ' * 4 * (level)
#         # print('{}{}/'.format(indent, os.path.basename(root)))
#         # subindent = ' ' * 4 * (level + 1)
#         # for f in files:
#         #     print('{}{}'.format(subindent, f))

#     return thisdict


# mydict = {}
# mydict['positivos'] = list_files('./www/tablas-diarias/', 'positivos')