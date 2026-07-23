---
geometry: margin=2cm
fontsize: 11pt
---

# 1. Objetivo

--

# 2. Metodología

## 2.1. Área de estudio

Con el fin de estudiar el efecto sobre la emisión de NO2 consecuencia de los [incedios ocurridos en la provincia de Chubut, Argentina, durante enero del 2025](https://www.infobae.com/salud/ciencia/2026/01/30/la-patagonia-argentina-sufre-el-incendio-mas-intenso-en-dos-decadas-segun-el-sistema-satelital-de-la-union-europea/) se definió un poligóno cuyos límites fueron: 72.35°O (-72.35°), 70.89°O (-70.89°), 41.95°S (-41.95°) y 43.36°S (-43.36°) **(ver Figura X)**. De esta forma, se incluyeron las áreas del Parque Nacional los Alerces, y las localidades de el Hoyo y Epuyén, que fueron las áreas y localidades más afectadas por este evento.
La definición del polígono se realizo a partir del acceso a la plataforma [NASA-FIRMS](https://firms.modaps.eosdis.nasa.gov/). Mediante esta, se pudo analizar la cantidad de superficie quemada detectadas, su ubicación y las fechas cuando ocurrieron a a través de los sensores de las plataformas MODIS y VIIRS. 

![alt text](report/images/fig0102.png)


## 2.2. Fuentes de datos

### 2.3.1. Datos producto $NO_{2}$

Para estudiar la afectación de la calidad del aire por la emisión de $NO_{2}$ producto de los incendios ocurridos en la Patagonia Argentina, dentro del área de estudio definida (ver ítem 2.1), se ha utilizado el producto *offline* de nivel 2 de $NO_{2}$ obtenido a partir del sensor TROPOMI a bordo de Sentinel-5P. Este producto provee la abundancia troposférica de dicho contaminante sobre la columna vertical medida en unidades de $mol/m^{2}$. 
El acceso, así como el procesamiento de los datos, se han realizado a través del [editor de código de Google Earth Engine (GEE)](https://code.earthengine.google.com/). De esta manera, estas tareas se ejecturon el entorno de una nube, prescindiendo de recursos computacionales propios.
Los datos de abundancia troposférica de $NO_{2}$ fueron adquiridos para dos periodos. Uno de ellos correspondió a un mes donde hubo nulos o pocos incendios, y el otro el cual se han registrado los incendios a estudiar, es decir enero del año 2026. Dentro del entorno de GEE se adquirieron todas las escenas para cada periodo y aplicando álgebra de bandas se obtuvo las composiciones temporales de: la cantidad de píxeles con datos (es decir sin nubes), y la suma, la mediana, y el desvío estandar de la abundancia píxel a píxel. 

### 2.3.2. Datos complementarios

Desde la plataforma de NASA-FIRMS, se han descargado datos de focos de calor del sensor MODIS correspondiente a los meses de febrero del año 2025 y enero del año 2026. Estos datos aportan información sobre si ocurrieron incendios y dónde lo hicieron en el área de estudio. Incorporarlos permite aporta evidencia sobre las diferencias ocurridas entre los periodos elegidos para el análisis. 

## 2.3. Análisis datos de $NO_{2}$

Los análisis implementados fueron realizado sobre las composiciones temporales de cantidad de píxeles con datos, y la mediana y el desvío estandar de la abundancia de $NO_{2}$ píxel a píxel para cada periodo. A partir de ellas se realizó un primer análisis que consistió en evaluar las zonas con una cantidad suficiente de datos por pixel. Asumiendo que en el lapso de un mes se deberian capturar alrededor de 30 escenas, se estableció un umbral de 15 datos por pixel. Todos aquellos que no cumplieran con dicho criterio fueron descartados. 
Habiendo identificado aquellas zonas del área de estudio que cumplian el umbral de cantidad mínima de datos, se continuó evaluando la distribución espacial de la mediana y el desvío estándar de la abundancia del $NO_{2}$. Adicionalmente, se analizó la relación entre el desvío estandary la mediana en el lapso de cada periodo. Esto se empleó como parámetro para evaluar si la variabilidad en el registro de $NO_{2}$ se correspondía a un evento puntual ($D. estandar > Mediana$) o a una condición permanente ($D. estandar < Mediana$) a lo largo del área de estudio.
Finalmente se evalúo estadísticamente si las diferencias entre los dos periodos analizados eran signicativas. Para ello se empleo un test de medias, asumiendo la independencia de los datos. 

# 3. Resultaods

## 2.1. 



| Clase | **Modelo 1** | **Modelo 2** |
|:-------|-------------:|-------------:|
| Bosque | 34 | 38 |
| Arbustal | 34 | 39 |
| Pastizal | 34 | 36 |
| Roca | 25 | 25 |
| Agua | 19 | 22 |
| Cultivo | 18 | 14 |
| Urbanización | 17 | 19 |
| **Total de polígonos** | **181** | **193** |
| **Total de píxeles** | **3307** | **2567** |

**Tabla X.** Comparación de los datos de entrenamiento utilizados en ambos modelos.


| Parámetro | **Modelo 1** | **Modelo 2** |
|:-----------------------------|:-------------:|:-------------:|
| Cantidad de árboles | 100 | 120 |
| Variables por ramificación | *Default* | 7 |
| Mínimo de elementos por ramificación | 1 | 3 |
| Fracción de datos por árbol | 1 | 0.8 |
| Semilla | *Default* (Aleatoria) | 42 |

**Tabla X.** Comparación de los parámetros utilizados para el entrenamiento de ambos modelos.




# Referencias

Cabido, M., Zeballos, S. R., Zak, M., Carranza, M. L., Giorgis, M. A., Cantero, J. J., & Acosta, A. T. R. (2018). Native woody vegetation in central Argentina: Classification of Chaco and Espinal  forests. Applied Vegetation Science, 21(2), 298–311.  
Cabrera, A. L. (1976). Regiones fitogeográficas argentinas. Enciclopedia Argentina de Agricultura  y Jardinería. Tomo II. Acme. 
Cingolani, A. M., Giorgis, M. A., Hoyos, L. E., & Cabido, M. (2022). La vegetación de las montañas de Córdoba (Argentina) a comienzos del siglo XXI: un mapa base para el ordenamiento territorial. Boletín de la Sociedad Argentina de Botánica, 57(1), 65–100. 
Giorgis, M. A., Cingolani, A. M., Chiarini, F., Chiapella, J., Barboza, G., Ariza Espinar, L., Morero,  R., Gurvich, D. E., Tecco, P. A., Subils, R., & Cabido, M. (2011). Composición florística del Bosque Chaqueño Serrano de la provincia de Córdoba, Argentina. Kurtziana, 36(1), 9–43.  