import re
from helpers import *

def parse_from_txt(source):
    
    queue = {
        'states': list(),
        'countries': list()
    }

    lines = {}
    
    with open(source, 'r') as reader:
        # Read and print the entire file line by line
        line = reader.readline()
        while line != '':
            if re.match(r"^\d+", line.strip()):
                append_new_line(line, lines, queue)

                line = reader.readline()

                continue
            
            # empty / header / footer lines
            if should_skip(line):
                line = reader.readline()
                continue

            # line doesn't start with number
            my_dict = extract_for_queue(line)

            # we need to append to the queue so it gets inserted
            # in next line!
            if 'state' in my_dict.keys():
                queue['states'].append(my_dict.get('state'))

            if 'country' in my_dict.keys():
                queue['countries'].append(my_dict.get('country'))                    

            line = reader.readline()

    return lines


def append_new_line(line, lines, queue):
    # so states / cities do not have spaces in between
    line = re.sub(r"(\w) (\w)", "\\1_\\2", line.strip())

    # replacing NAs
    line = re.sub(r",NA,", ",,", line.strip())

    # replace space with commas
    line = re.sub("\s+", ",", line.strip())

    # bring back spaces
    line = line.replace("_", " ")

    parts = line.split(',')
    
    print("Processing line...{}".format(parts[0]))

    if len(queue['states']):
        state = queue['states'].pop()

        # element after first comma is a gender, we insert...
        if parts[1].upper() in genders():
            parts.insert(1, state)
        # otherwise we append text
        else:
            temp = parts[1]
            parts[1] = "{} {}".format(state, temp)
        
        # we validate text is actually a normalized state
        if not is_mx_state(parts[1]):
            exit("Invalid MX state found {}".format(parts[1]))

    if len(queue['countries']):
        country = queue['countries'].pop()

        # if there are 8 elements
        if len(parts) == 8 or len(parts) == 7:
            temp = parts[6]
            parts[6] = "{} {}".format(country, temp)

        if not is_known_country(parts[6]):
            exit("Invalid Country found {}".format(parts[6]))

    lines[parts[0]] = parts


def extract_for_queue(line):
    print("Extracting for queue...")

    # converting spaces to -
    text = re.sub(r"(\w) (\w)", "\\1_\\2", str(line))
    # converting spaces to -
    text = re.sub(r"\s", "-", text).rstrip('-')

    regex = re.compile(r'(-+[\w]+)')

    matches = re.match(regex, text)

    counts = 0

    my_dict = {}

    countries = ['Estados', 'República']

    while matches: 
        print("Processing text {}".format(text))

        match = matches.group()

        to_queue = re.sub(r"_", " ", match.strip('-').strip())

        # making sure state is in the first 40 chars
        # see: https://datos.covid19in.mx/tablas-diarias/positivos/202004/20200405.txt
        if is_mx_state(to_queue) and match.count('-') < 40:
            print("Queueing State!! {}".format(to_queue))
            my_dict['state'] = to_queue
        elif to_queue in countries:
            print("Queueing Country!! {}".format(to_queue))
            my_dict['country'] = to_queue            
        elif to_queue == "México" and match.count('-') > 40:
            print("empty line.. nothing to do")
        else:
            print("Unable to know what to queue")
            exit()

        text = text.replace(match, '').rstrip('-')
        matches = re.match(regex, text)

    return my_dict


def should_skip(line):
    text = re.sub(r"\s+", "-", line).rstrip('-')

    # Empty lines
    if text.strip() == '':
        return True

    # Footer
    if re.search(r"F:-+Femenino|13:00-+horas|SINAVE/DGE/InDR", text):
        return True

    # Header
    if re.search(r"Casos-+Confirmados", text):
        return True

    if re.search(r"Fecha-+de|tiempo-real|COVID-19|RT-PCR", text):
        return True   

    if re.search(r"Sexo|Identificación|síntomas", text):
        return True

    # Header
    if line.strip() == 'real':
        return True

    return False 


def get_col_names_for_txt(df):
    headers =  [
        'Caso', 'Estado', 'Sexo', 'Edad',  'Fecha_Sintomas',  'Situacion'
    ]

    if len(df.columns) == 9:
        headers.append(2, 'Localidad')
    
    if len(df.columns) == 8:
        headers.append('Procedencia')
        headers.append('Fecha_Llegada')

    if len(df.columns) == 7:
        headers.append('Procedencia')

    if len(df.columns) < 6:
        print(df)
        exit('Check headers!')

    return headers
    