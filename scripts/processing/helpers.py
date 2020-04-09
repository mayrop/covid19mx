import datetime
import re
import requests
from pathlib import Path


#----------------------------------------------------------------
# F i l  e s
#----------------------------------------------------------------

def _get_from_cache(url, name=''):
    file = cache_file(url, name)

    if file.is_file():
        return file.read_text()


def cache_file(url, name=''):
    if not name:
        name = '{}'.format(
            hashlib.sha224(url.encode()).hexdigest()
        )

    path = '{}.txt'.format(name)
    
    return Path(path)


def _get_from_remote(url):
    """
        This is hardcoded to our needs, need to fix
    """
    headers = {
        'Content-Type': 'application/json; charset=UTF-8'
    }

    response = requests.post(url, headers=headers)

    return response.text


def request_url(url, name='', wait=1):
    content = _get_from_cache(url, name)

    if not content:
        content = _get_from_remote(url)
        cache_file(url, name).write_bytes(content.encode())

    return content



#----------------------------------------------------------------
# S t r i n g s
#----------------------------------------------------------------

def convert_na(text):
    if text == "NA":
        return ""  
    
    return text


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


# https://stackoverflow.com/questions/15325182/how-to-filter-rows-in-pandas-by-regex
def regex_filter(val, regex):
    if val:
        mo = re.search(regex, val, re.IGNORECASE)
        if mo:
            return True
        else:
            return False
    else:
        return False    


#----------------------------------------------------------------
# S t r i n g s
#----------------------------------------------------------------

# replacing excel dates
# see: https://stackoverflow.com/questions/14271791/converting-date-formats-python-unusual-date-formats-extract-ymd
def get_fixed_date(text):
    if not is_date_in_excel_format(text):
        return text
    
    match = re.search(r'(\d{5})', text)
    m = match.group().replace(" ", "").replace(",","")
    delta = datetime.timedelta(int(m)-2)
    date = datetime.date(1900, 1, 1) + delta
    date = str(date.strftime("%d/%m/%Y"))
    
    return date


def is_date_in_excel_format(text):
    match = re.search(r'(\d{5})', text)
    
    if match:
        return True
    
    return False


#----------------------------------------------------------------
# C o n t e x t
#----------------------------------------------------------------

def get_iso_from_state(state):

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

