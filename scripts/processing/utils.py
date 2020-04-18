import os

#----------------------------------------------------------------
# P r o j e c t
#----------------------------------------------------------------

ROOT_DIR = os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))
)) # This is your Project Root
CACHE_DIR = 'cache'
CACHE_MAP_DIR = '/cache/mapa/'

URL_PDFS = 'https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449'

URL_CASES_MAP = 'https://covid19.sinave.gob.mx/Log.aspx/Grafica22'
URL_VALUATION_MAP = 'https://covid19.sinave.gob.mx/MapaTasas.aspx/Grafica22'

URL_ZIP = 'https://www.gob.mx/salud/documentos/datos-abiertos-152127'