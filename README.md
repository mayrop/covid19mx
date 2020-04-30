# `@datos-covid19in-mx`

[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg?style=flat-square)](http://commitizen.github.io/cz-cli/) <!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)<!-- ALL-CONTRIBUTORS-BADGE:END -->

##### :es: Versión en Español. <!-- UPDATE_ES:START - Do not remove or modify this section -->Última Actualización: 2020-04-29<!-- UPDATE_ES:END -->

# COVID-19 en México 🇲🇽
Datos de en formato PDF, CSV y TXT de los casos COVID-19 (Novel Coronavirus) en México. Datos adicionales para ayudar al análisis que incluyen las coordenadas geográficas (centroides) de cada municipio y entidad federativa, así como la proyección de población del año 2020 de cada una de ellas. Todos los datos obtenidos de fuentes oficiales. Próximamente estadísticas y análsis.

## Información :information_source:
* Sitio web: https://www.covid19in.mx/  
* Repositorio para el sitio web: https://github.com/mayrop/covid19in-mx 
* **Paquete R**: https://github.com/mayrop/datosmx

Los archivos dentro de la carpeta www son accesibles por medio web a través del dominio https://datos.covid19in.mx/, por ejemplo [20200313.pdf](/www/tablas-diarias/positivos/202003/20200313.pdf) es accesible [aquí](https://datos.covid19in.mx/tablas-diarias/positivos/202003/20200313.pdf).

## Datos Disponibles :chart_with_upwards_trend:
* [Datos Abiertos - COVID-19 en México](/www/abiertos/todos/202004). _<!-- UPDATE-OPENDATA_ES:START - Do not remove or modify this section -->Última Actualización: 2020-04-29<!-- UPDATE-OPENDATA_ES:END -->_  
  * [Series de Tiempo](https://www.covid19in.mx/datos/series-de-tiempo/). Construidas a partir de los datos abiertos (desde el 12 de Abril de 2020), y del mapa interactivo antes para datos antes del 12 de Abril de 2020. _<!-- UPDATE-TIMESERIES_ES:START - Do not remove or modify this section -->Última Actualización: 2020-04-29<!-- UPDATE-TIMESERIES_ES:END -->_  
* [Tablas Diarias de Casos Positivos y Sospechosos (Comunicado Técnico Diario)](https://www.covid19in.mx/docs/datos/tablas-casos/).  
  * Las cuales fueron deprecadas el 19 de Abril de 2020, cuando la SSa dejó de publicarlas. 
* Coordenadas Geográficas de cada uno de los [municipios](/www/otros/ciudades.csv) y [entidades federativas](/www/otros/estados.csv) en México.
* Población (2019) de cada uno de los [municipios](/www/otros/ciudades.csv) y [entidades federativas](/www/otros/estados.csv) en México.


---------------------------------------------

## Fuentes :memo:

### [Datos Abiertos - COVID-19](https://www.gob.mx/salud/documentos/datos-abiertos-152127) 
Fuente Oficial: https://www.gob.mx/salud/documentos/datos-abiertos-152127

Datos abiertos de los casos COVID-19 Novel Coronavirus en México.

Disponibilidad:
* Datos disponibles en formato ZIP desde el 13/04/2020 después de que el Director General de Promoción de la Salud del Gobierno de México, [Ricardo Cortes Alcala](https://twitter.com/RicardoDGPS) anunciara [su disponibilidad](https://twitter.com/RicardoDGPS/status/1249864573936644096)

### [Comunicado Técnico Diario (COVID-19)](https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449) 
Fuente Oficial: https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449  

Usado para las tablas diarias de casos positivos y sospechosos. Detalles [aquí](https://www.covid19in.mx/docs/datos/tablas-casos/).
Disponibilidad: 
* Datos diarios en formato PDF, CSV y TXT para casos positivos, desde el 13 de Marzo de 2020.
* Datos diarios en formato PDF, CSV y TXT para casos sospechosos, desde el 11 de Marzo de 2020. Se cuenta ademas con la tabla del dia 8 de Marzo, 2020.

### [Mapa Interactivo de México (COVID-19)](https://ncov.sinave.gob.mx/mapa.aspx) 
Fuente Oficial: https://ncov.sinave.gob.mx/mapa.aspx  

Usado para obtener las series diarias de datos. Detalles [aquí](https://www.covid19in.mx/docs/datos/series-de-tiempo/).
Disponibilidad: 
* Datos segregados por fecha y estados en formato CSV para casos positivos y sospechosos están disponibles desde el 13/03/2020. Dichos datos fueron obtenidos a partir del Comunicado Técnico Diario.
* Datos segregados por fecha y estados en formato CSV por fecha y estados para casos positivos, sospechosos, negativos y defunciones a partir del mapa están disponibles desde el 4 de Abril de 2020. Los datos acumulados para los casos negativos y defunciones antes del 4 de Abril fueron capturados manualmente a partir del Comunicado Técnico Diario. Favor de reportar cualquier error via  [Twitter](https://twitter.com/mayrop) o como un issue en Github.

### Marco Geoestadístico de México 🇲🇽 
* Fuente oficial: https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=889463142683

Se tiene una base de datos de [2458 municipios](/www/otros/ciudades.csv) de México, y otra de las [32 entidades federativas](/www/otros/estados.csv) en México (31 estados y la Ciudad de México). Los datos presentados están en formato CSV con las coordenadas (centroides) correspondientes cada municipio (o estado), obtenidos a partir del Marco Geoestadístico, junio 2017, diseñado por el INEGI. Los mismos datos en formato SHP pueden encontrarse en la fuente oficial.

 ### Población del 2019 de México 🇲🇽 
* Fuente oficial: https://datos.gob.mx/busca/dataset/proyecciones-de-la-poblacion-de-mexico-y-de-las-entidades-federativas-2016-2050/resource/0cda121e-5e8f-48a0-9468-d2cc921f3f3c?inner_span=True

Se tiene una base datos en formato CSV de la población de [2457 municipios](/www/otros/ciudades.csv) y [32 entidades federativas](/www/otros/estados.csv) de México del año 2019. Obtenida de las [Proyecciones de la Población de los Municipios de México, 2015-2030](https://datos.gob.mx/busca/dataset/proyecciones-de-la-poblacion-de-mexico-y-de-las-entidades-federativas-2016-2050/resource/0cda121e-5e8f-48a0-9468-d2cc921f3f3c?inner_span=True) generada por el Consejo Nacional de Población (CONAPO). Descargada el día 15/04/2020 (en donde los datos tienen fecha última de actualización del 23 de Agosto de 2019). **_Nota:_** _Existe un municipio (Puerto Morelos, Quintana Roo), el cual no esta disponible en la base de datos de las proyecciones de población, pero esta disponible en la base de datos del Marco Geoestadístico de México. Al parecer se encuentra [en vigor desde](https://es.wikipedia.org/wiki/Municipio_de_Puerto_Morelos) el 2016 (documento [oficial](https://web.archive.org/web/20151222080644/http://www.congresoqroo.gob.mx/historial/14_legislatura/decretos/3anio/1PO/dec342/D1420151029342.pdf))_.

------------------------------------------ 
##### :uk: English Version. <!-- UPDATE_EN:START - Do not remove or modify this section -->Last Update: 2020-04-29<!-- UPDATE_EN:END -->

# COVID-19 in México 🇲🇽
Data in PDF, CSV and TXT about the COVID-19 (Novel Coronavirus) cases in México. Additional data to help analysis which includes the geographic coordinates (centroids) of each city and state in México, as well as the 2020 population for each one of them. All of the obtained data comes from official sources. There will be statistics and analysis very soon.

## Information :information_source:
* Website: https://www.covid19in.mx/
* Repository for the web site: https://github.com/mayrop/covid19in-mx 
* **R Package**: https://github.com/mayrop/datosmx

The files inside the www folder can be accessed through the web through the https://datos.covid19in.mx/ domain. For example, [20200313.pdf](/www/tablas-diarias/positivos/202003/20200313.pdf) can be accessed [here](https://datos.covid19in.mx/tablas-diarias/positivos/202003/20200313.pdf).

## Available Data :chart_with_upwards_trend:
* [Open Data - COVID-19 in México](/www/abiertos/todos/202004). <!-- UPDATE-OPENDATA_EN:START - Do not remove or modify this section -->Last Update: 2020-04-29<!-- UPDATE-OPENDATA_EN:END -->  
  * [Time Series](https://www.covid19in.mx/en/data/time-series/)
* [Daily Tables for Positive and Suspected Cases (Daily Technical Release)](https://www.covid19in.mx/docs/datos/tablas-casos/)
* Geographic Coordinates for each one of the [cities](/www/otros/ciudades.csv) and [states](/www/otros/estados.csv) in México.
* Population (2020) for each one of the [cities](/www/otros/ciudades.csv) y [states](/www/otros/estados.csv) in México.

## Official Sources :memo:

### [Open Data - COVID-19](https://www.gob.mx/salud/documentos/datos-abiertos-152127) 
Official Source: https://www.gob.mx/salud/documentos/datos-abiertos-152127

Open Data in ZIP/CSV format for the COVID-19 Novel Coronavirus cases in México.

Availability:
* Data available in ZIP format since April 13 2020, after [Ricardo Cortes Alcala](https://twitter.com/RicardoDGPS), General Director of Health Promotion of the Government of Mexico, announced [its availability](https://twitter.com/RicardoDGPS/status/1249864573936644096)

### [Daily Technical Release (COVID-19)](https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449) 
Official Source: https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449  

Used for the daily tables of positive and suspected cases. Details [aquí](https://www.covid19in.mx/en/data/cases-tables/).

Availability: 
* Daily data in PDF, CSV and TXT format for positive cases, since March 13, 2020.
* Daily data in PDF, CSV and TXT format for suspected cases, since March 11, 2020. An addition of the data is available too for March 8, 2020.

### [Interactive Map of México (COVID-19)](https://ncov.sinave.gob.mx/mapa.aspx) 
Official Source: https://ncov.sinave.gob.mx/mapa.aspx  

Used to obtain daily timeseries. Details [here](https://www.covid19in.mx/en/data/time-series/).

Availability: 
* Data segregated by date and state in CSV format for positive and suspected caes since March 13, 2020. Data obtained from Daily Technical Release.
* Data segrated by date and state in CSV format for positive, suspected, negative and deaths form the map since April 4, 2020. Accumulated data for deaths and negative cases prior to April 4, 2020 was captured manually from the Daily Technical Release. Please report any error through [Twitter](https://twitter.com/mayrop) or through a Github issue.

### Geostatistical Data de México 🇲🇽 
Official Source: https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=889463142683

Data base with [2458 cities](/www/otros/ciudades.csv) in México, and a different one for the [32 states](/www/otros/estados.csv) in México. Data is presented in CSV format with the geographical coordinates (centroids) for each city and state. Data obtained from the  obtenidos a partir del Geostatistical Data, June 2017, from INEGI. Complete data SHP format can be obtained from the original source.

 ### 2019 Population in México 🇲🇽 
Official Source: https://datos.gob.mx/busca/dataset/proyecciones-de-la-poblacion-de-mexico-y-de-las-entidades-federativas-2016-2050/resource/0cda121e-5e8f-48a0-9468-d2cc921f3f3c?inner_span=True

Database in CSV format for the population of [2457 cities](/www/otros/ciudades.csv) and [32 states](/www/otros/estados.csv) in México for 2019. Obtained from the [Proyecciones de la Población de los Municipios de México, 2015-2030](https://datos.gob.mx/busca/dataset/proyecciones-de-la-poblacion-de-mexico-y-de-las-entidades-federativas-2016-2050/resource/0cda121e-5e8f-48a0-9468-d2cc921f3f3c?inner_span=True), generated by the Consejo Nacional de Población (CONAPO) (National Population Council). Downloaded on April 15, 2020 (where the data had a last updated time August 23, 2019). **_Note:_** _There is a city (Puerto Morelos, Quintana Roo), that is not available. Apparently this city was [created on 2016](https://es.wikipedia.org/wiki/Municipio_de_Puerto_Morelos) (official [document](https://web.archive.org/web/20151222080644/http://www.congresoqroo.gob.mx/historial/14_legislatura/decretos/3anio/1PO/dec342/D1420151029342.pdf))_.

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://twitter.com/mayrop"><img src="https://avatars0.githubusercontent.com/u/495985?v=4" width="100px;" alt=""/><br /><sub><b>Mayra Valdés</b></sub></a><br /><a href="https://github.com/mayrop/datos-covid19in-mx/commits?author=mayrop" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!