##### :es: Versión en Español. Ultima Actualización: 16/04/2020

# COVID-19 en México 🇲🇽
Datos de los casos COVID-19 en México. Datos adicionales para ayudar al análisis que incluyen las coordenadas de cada municipio y entidad federativa (centroides), así como la proyección de población del año 2020 de cada una de ellas. Todos los datos obtenidos de fuentes oficiales. Próximamente estadísticas y análsis.

## :information_source: Información
* Sitio web: https://www.covid19in.mx/  
* Repositorio para el sitio web: https://github.com/mayrop/covid19in-mx 
* **Paquete R**: https://github.com/mayrop/r-covid19in-mx 

Los archivos dentro de la carpeta www son accesibles por medio web a través del dominio https://datos.covid19in.mx/, por ejemplo [20200313.pdf](/www/tablas-diarias/positivos/202003/20200313.pdf) es accesible [aquí](https://datos.covid19in.mx/tablas-diarias/positivos/202003/20200313.pdf).

## :memo: Fuentes:

### [Datos Abiertos - COVID-19](https://www.gob.mx/salud/documentos/datos-abiertos-152127) 
Fuente Oficial: https://www.gob.mx/salud/documentos/datos-abiertos-152127

Datos abiertos de los casos COVID-19 Novel Coronavirus en México.

Disponibilidad:
* Datos disponibles en formato ZIP desde el 13/04/2020 después de que el Director General de Promoción de la Salud del Gobierno de México, [Ricardo Cortes Alcala](https://twitter.com/RicardoDGPS) anunciara [su disponibilidad](https://twitter.com/RicardoDGPS/status/1249864573936644096)

**Ultima Fecha de Actualización:** 16/04/2020

### [Comunicado Técnico Diario](https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449) 
Fuente Oficial: https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449
Usado para las tablas diarias de casos positivos y sospechosos. Detalles [aquí](https://www.covid19in.mx/docs/datos/tablas-casos/).
Disponibilidad: 
* Datos diarios en formato PDF, CSV y TXT para casos positivos, desde el 13/03/2020.
* Datos diarios en formato PDF, CSV y TXT para casos sospechosos, desde el 11/03/2020. Se cuenta ademas con la tabla del dia 8 de Marzo, 2020.

**Ultima Fecha de Actualización:** 16/04/2020

### [Mapa Interactivo de México - Casos y Tasas (COVID-19)](https://ncov.sinave.gob.mx/mapa.aspx) 
Fuente Oficial: https://ncov.sinave.gob.mx/mapa.aspx
Usado para obtener las series diarias de datos. Detalles [aquí](https://www.covid19in.mx/docs/datos/series-de-tiempo/).
Disponibilidad: 
* Datos segregados por fecha y estados en formato CSV para casos positivos y sospechosos están disponibles desde el 13/03/2020. Dichos datos fueron obtenidos a partir del Comunicado Técnico Diario.
* Datos segregados por fecha y estados en formato CSV por fecha y estados para casos positivos, sospechosos, negativos y defunciones a partir del mapa están disponibles desde el 04/04/2020. Los datos acumulados para las defunciones y fallecimientos antes del 04/04/2020 fueron capturados manualmente a partir del Comunicado Técnico Diario. Favor de reportar cualquier error via  [Twitter](https://twitter.com/mayrop) o como un issue en Github.

**Ultima Fecha de Actualización:** 16/04/2020

### Marco Geoestadístico de México
* Fuente oficial: https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=889463142683

Se tiene una base de datos de [2458 municipios](/www/otros/ciudades.csv) de México, y otra de las [32 entidades federativas](/www/otros/estados.csv) en México (31 estados y la Ciudad de México). Los datos presentados están en formato CSV con los las coordenadas (centroides) correspondientes cada municipio (o estado), obtenidos a partir del Marco Geoestadístico, junio 2017, diseñado por el INEGI. Los mismos datos en formato SHP pueden encontrarse en la fuente oficial.

**Ultima Fecha de Actualización:** 15/04/2020

 ### Población del 2020 de México
* Fuente oficial: https://datos.gob.mx/busca/dataset/proyecciones-de-la-poblacion-de-mexico-y-de-las-entidades-federativas-2016-2050/resource/0cda121e-5e8f-48a0-9468-d2cc921f3f3c?inner_span=True

Se tiene una base datos en formato CSV de la población de [2457 municipios](/www/otros/ciudades.csv) y [32 entidades federativas](/www/otros/estados.csv) de México del año 2020. Obtenida a partir de las [Proyecciones de la Población de los Municipios de México, 2015-2030](https://datos.gob.mx/busca/dataset/proyecciones-de-la-poblacion-de-mexico-y-de-las-entidades-federativas-2016-2050/resource/0cda121e-5e8f-48a0-9468-d2cc921f3f3c?inner_span=True) generada por el Consejo Nacional de Población (CONAPO). Descargada el día 15/04/2020 (en donde los datos tienen fecha última de actualización 23/08/2019). **_Nota:_** _Existe un municipio (Puerto Morelos, Quintana Roo), el cual no esta disponible en la base de datos de las proyecciones de población, pero esta disponible en la base de datos del Marco Geoestadístico de México. Al parecer se encuentra [en vigor desde](https://es.wikipedia.org/wiki/Municipio_de_Puerto_Morelos) el 2016 (documento [oficial](https://web.archive.org/web/20151222080644/http://www.congresoqroo.gob.mx/historial/14_legislatura/decretos/3anio/1PO/dec342/D1420151029342.pdf))_.

**Ultima Fecha de Actualización:** 15/04/2020

------------------------------------------ 
##### :uk: English Version 

# COVID-19 in México 🇲🇽
Information about the COVID-19 cases in México.

## :information_source: Information:
* Website: https://www.covid19in.mx/
* Repository for the web site: https://github.com/mayrop/covid19in-mx 
* R Package: https://github.com/mayrop/r-covid19in-mx 

The files inside the www folder can be accessed through the https://datos.covid19in.mx/ domain. For example, the file [20200313.pdf](/www/tablas-diarias/positivos/202003/20200313.pdf) can be found [here](https://datos.covid19in.mx/tablas-diarias/positivos/202003/20200313.pdf).

## :memo: Sources:
* https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449
* http://ncov.sinave.gob.mx/mapa.aspx
