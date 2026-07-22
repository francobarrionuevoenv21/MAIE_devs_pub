---
geometry: margin=2cm
fontsize: 11pt
---

# 1. Objetivo

--

# 2. Metodología

## 2.1. Área de estudio

Con el fin de estudiar el efecto sobre la emisión de NO2 consecuencia de los [incedios ocurridos en la provincia de Chubut, Argentina, durante enero del 2025](https://www.infobae.com/salud/ciencia/2026/01/30/la-patagonia-argentina-sufre-el-incendio-mas-intenso-en-dos-decadas-segun-el-sistema-satelital-de-la-union-europea/) se definió un poligóno cuyos límites fueron: 72.35°O (-72.35°), 70.89°O (-70.89°), 41.95°S (-41.95°) y 43.36°S (-43.36°) **(ver Figura X)**. De esta forma, se incluyeron las áreas del Parque Nacional los Alerces, y las localidades de el Hoyo y Epuyén, que fueron las áreas y localidades más afectadas por este evento.
La definición del polígono se realizo a partir del acceso a la plataforma [NASA-FIRMS](). Mediante esta, se pudo analizar la cantidad de superficie quemada detectadas, su ubicación y las fechas cuando ocurrieron a a través de los sensores de las plataformas MODIS y VIIRS. 

![alt text](report/images/fig0102.png)

*asa*

## 2.2. Fuentes de datos

### 2.3.1. Datos producto $NO_{2}$

Para estudiar la afectación de la calidad del aire por la emisión de $NO_{2}$ producto de los incendios ocurridos en la Patagonia Argentina, dentro del área de estudio definida (ver ítem 2.1), se ha utilizado el producto *offline* de nivel 2 de $NO_{2}$ obtenido a partir del sensor TROPOMI a bordo de Sentinel-5P. Este producto provee la abundancia troposférica de dicho contaminante sobre la columna vertical medida en unidades de $mol/m^{2}$. 
El acceso, así como el procesamiento de los datos, se han realizado a través del [editor de código de Google Earth Engine (GEE)](https://code.earthengine.google.com/). De esta manera, estas tareas se ejecturon el entorno de una nube, prescindiendo de recursos computacionales propios.
Los datos de abundancia troposférica de $NO^{2}$ fueron adquiridos para dos periodos. Uno de ellos correspondió a un mes donde hubo nulos o pocos incendios, y el otro el cual se han registrado los incendios a estudiar, es decir enero del año 2026. Dentro del entorno de GEE se adquirieron todas las escenas para cada periodo y aplicando álgebra de bandas se obtuvo: la cantidad de píxeles con datos (es decir sin nubes), y la suma, la mediana, y el desvío estandar de la abundancia píxel a píxel. 

### 2.3.2. Datos complementarios

## 2.3. Análisis de ...


## 2.4. Clasificación y evaluación de los resultados

### 2.4.1. Modelo empleado

La ejecución de la clasificación para la posterior elaboración de los mapas de coberturas en el área de estudio, se realizó empleando el modelo de clasificación *Random Forest* (RF). Este tipo de modelo de machine learning se caracteriza por construir múltiples árboles de decisión durante el entrenamiento, en lugar de depender de un solo árbol. Luego combina las predicciones de todos ellos, mediante votación o promediando, lo que da un resultado más estable. 

Este paso, al igual que en el ítem 2.3, se ha realizado en la nube a través de la infraestructura de GEE, y se ha empleado el clasificador *SMILE Random Forest*, el cual arroja como resultado la clase más votada entre todos los árboles. Su configuración incluye una serie de parámetros tales como la cantidad de árboles, la cantidad de variables por división, y la fracción de los datos a usar durante el entranamiento de cada arbol, entre otros. 

### 2.4.2. Datos de entrenamiento

El entrenamiento del modelo se realizó a partir de muestras extraídas sobre las bandas de reflectancia 2-12 de las dos escenas de S2 (época seca y época húmeda), los índices derivados para cada escena, y el MDE. Las muestras, por un lado, se obtuvieron a partir de polígonos alrededor de los puntos donde habían datos de campo. A estos se le sumaron polígonos previamente cargadas y clasificados, junto a nuevos polígonos de generados a partir de la inspección visual de las imágenes de S8. A cada uno de ellos se le asignó alguna de las siguientes categorías según conocimientos previos del área y de la jornada de recolección de datos de campo: bosque, arbustal, pastizal, roca, agua, cultivo y urbanización. 

El total de muestras, posteriormente, se dividió en un subconjunto de entrenamiento y en otro de testeo. La asignación fue aleatoria, y la proporción se definió en 70% de los datos para el entrenamiento, y el 30% restante para el testeo del modelo y el cómputo de los parámetros de evaluación de su performance.

### 2.4.3. Evaluación del modelo y pruebas

Los resultados de las clasificaciones ejecutadas fueron evaluadas a partir de su matriz de confusión, la exactitud del usuario (EU), la exactitud del productor (EP) y la exactitud global (EG). Bajo estos criterios, se realizaron dos clasificaciones en total, donde en cada una se han modificado los polígonos de muestreo (incluido y/o eliminado) y los parámetros del modelo. Las modificaciones realizadas tuvieron como objetivo la búsqueda de la mejora en los resultados de la clasificación. 

# 3. Resultados

## 3.1. Datos de campo

Tal como se ha mencionado en el ítem 2.3.1, a los datos recolectados la jornada del 25 de junio del 2025 en el CETT, se le sumaron los de registros previos. En total sumaron 21 puntos sobre los cuales se contaba con información de campo sobre la cobertura y/o uso del suelo entre la ciudad de Malagueno y Villa Carlos Paz (Figura X.A) y dentro del predio del centro espacial (Figura X.B). 

Los diferentes puntos se relacionaron a las clases definidas en el ítem 2.4.2 según cómo fueron identificadas. De esta forma, 10 fueron asignados a arbustal, 7 a bosque, 3 a pastizal y 1 a urbanización. 

![alt text](qgis/images/fig0102.png)


## 3.2. Ajuste y evaluación del modelo de clasificación

Con el objetivo de hallar un modelo que clasifique con una mayor precisión las coberturas en el área de estudio, se realizaron dos instancias de entrenamiento del algoritmo *Random Forest*. La primera se utilizó como línea de base para evaluar el comportamiento inicial del modelo, mientras que la segunda incorporó modificaciones tanto en los datos de entrenamiento como en los parámetros del clasificador, definidas a partir del análisis de los resultados obtenidos en la primera prueba.

En ambos casos se emplearon los mismos datos de campo relevados (21 polígonos; ver ítem 3.1), complementados con polígonos digitalizados mediante inspección visual de las imágenes S2 correspondientes a las épocas seca y húmeda. La **Tabla X** resume la cantidad de polígonos utilizados por clase en cada uno de los modelos.

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

Además de modificar el conjunto de entrenamiento, también se ajustaron los parámetros del clasificador. En particular, en el segundo modelo se incrementó la cantidad de árboles, se definió explícitamente el número de variables consideradas en cada ramificación, se aumentó el mínimo de elementos por nodo, se redujo la fracción de datos utilizada para entrenar cada árbol y se fijó la semilla del algoritmo para garantizar la reproducibilidad de los resultados. La **Tabla X** resume la configuración empleada en cada caso.

| Parámetro | **Modelo 1** | **Modelo 2** |
|:-----------------------------|:-------------:|:-------------:|
| Cantidad de árboles | 100 | 120 |
| Variables por ramificación | *Default* | 7 |
| Mínimo de elementos por ramificación | 1 | 3 |
| Fracción de datos por árbol | 1 | 0.8 |
| Semilla | *Default* (Aleatoria) | 42 |

**Tabla X.** Comparación de los parámetros utilizados para el entrenamiento de ambos modelos.

Los resultados de ambas clasificaciones se muestran en la **Figura X**. El primer modelo alcanzó una precisión global cercana al 85%, mientras que el segundo obtuvo una precisión superior al 94%, lo que representa una mejora aproximada del 11%.

En el primer modelo, la clase **arbustal** presentó la menor precisión del productor (61%), indicando que una proporción importante de los píxeles de referencia pertenecientes a esta clase fue clasificada principalmente como bosque. Asimismo, la clase **agua** registró la menor precisión del usuario (56%), debido a que una fracción considerable de los píxeles clasificados como agua correspondía en realidad a otras clases, principalmente urbanización.

Luego de incorporar las modificaciones propuestas, el segundo modelo mostró una mejora general en todas las métricas de evaluación. La clase **arbustal** continuó presentando la menor precisión del productor (84%), aunque con un incremento significativo respecto del primer modelo. Los píxeles de referencia que no fueron correctamente clasificados se asignaron principalmente a las clases bosque y pastizal. Por su parte, las clases **pastizal** y **roca** registraron la menor precisión del usuario (83% y 86%, respectivamente). En el primer caso, una fracción de los píxeles clasificados como pastizal correspondía en realidad a arbustal, mientras que en el segundo algunos píxeles clasificados como roca pertenecían a la clase cultivo.

![alt text](qgis/images/fig04.png)

**Figura X.** Comparación de los resultados obtenidos mediante el primer (izquierda) y segundo (derecha) modelo de clasificación.

La comparación visual confirma la mejora reflejada por los parámetros de evaluación. En el primer modelo se observan errores evidentes, como la clasificación de áreas urbanas o de cultivo como agua, asociados principalmente al desbalance entre clases y a la configuración inicial del clasificador. En el segundo modelo estos errores se reducen considerablemente, aunque aún persisten algunas confusiones entre las clases cultivo, urbanización y roca.

Bajo el resultado obtenido con el segundo modelo, se observa que el área de estudio presenta un predominio de las clases **pastizal** y **arbustal**, que ocupan aproximadamente un 25% de la superficie total cada una. Si bien el ajuste realizado permitió mejorar significativamente el desempeño del clasificador, el trabajo futuro deberá centrarse en incorporar nuevos datos de entrenamiento representativos y explorar configuraciones alternativas del algoritmo con el fin de reducir las confusiones remanentes entre clases espectralmente similares.


# Referencias

Cabido, M., Zeballos, S. R., Zak, M., Carranza, M. L., Giorgis, M. A., Cantero, J. J., & Acosta, A. T. R. (2018). Native woody vegetation in central Argentina: Classification of Chaco and Espinal  forests. Applied Vegetation Science, 21(2), 298–311.  
Cabrera, A. L. (1976). Regiones fitogeográficas argentinas. Enciclopedia Argentina de Agricultura  y Jardinería. Tomo II. Acme. 
Cingolani, A. M., Giorgis, M. A., Hoyos, L. E., & Cabido, M. (2022). La vegetación de las montañas de Córdoba (Argentina) a comienzos del siglo XXI: un mapa base para el ordenamiento territorial. Boletín de la Sociedad Argentina de Botánica, 57(1), 65–100. 
Giorgis, M. A., Cingolani, A. M., Chiarini, F., Chiapella, J., Barboza, G., Ariza Espinar, L., Morero,  R., Gurvich, D. E., Tecco, P. A., Subils, R., & Cabido, M. (2011). Composición florística del Bosque Chaqueño Serrano de la provincia de Córdoba, Argentina. Kurtziana, 36(1), 9–43.  