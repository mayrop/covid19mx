import re
import requests
from pathlib import Path


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