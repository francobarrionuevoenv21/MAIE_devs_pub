---
geometry: margin=2cm
fontsize: 11pt
---

# 1. Objetivo

El objetivo principal consistió en adquirir nociones básicas vinculadas a la elaboración de mapas de coberturas y uso del suelo a partir de clasificaciones supervisadas de imágenes satelitales.  

Este trabajo estuvo organizado en tres etapas. La primera abordó la recolección de  datos de referencia para entrenar y validar la clasificación, y la selección y preparación de las imágenes satelitales sobre las cuales se realizó la clasificación. La segunda consistió en la ejecución de la clasificación propiamente dicha, mientras que en la tercera etapa se hace una validación o verificación de la  exactitud del producto generado. 

# 2. Metodología

## 2.1. Área de estudio

El área sobre la cual se ha trabajado pertenece a las denominadas Sierras Chicas (SSCC) de la Provincia de Córdoba (Argentina). Las sierras ocupan una superficie de 810.000 ha y comprenden un gradiente de elevaciones entre 500 y 1950 m snm. El clima es templado semiárido, con un régimen de precipitaciones monzónico. El promedio anual de precipitaciones es de 850 mm, concentradas principalmente en el semestre más cálido, entre Septiembre y Marzo, dando lugar a inviernos secos y veranos húmedos. La temperatura media anual de 17,3 °C. La vegetación se clasifica como perteneciente al distrito Chaqueño Serrano, que es la porción más austral del bosque de estación seca conocido como Gran Chaco Americano (Cabrera, 1976). 

La vegetación en las SSCC consiste en un mosaico de bosques, arbustales y pastizales distribuidas a lo largo de todo el gradiente altitudinal (Cabido et al., 2018; Cingolani et al., 2022; Giorgis et al., 2011). Los bosques están dominados por *Lithraea molleoides* (nombre común: Molle) y *Zanthoxylum coco* (nombre común: Coco), pudiendo presentar un estrato arbóreo altamente desarrollado, con coberturas superiores al 80 % y alturas entre 5 y 9 m. Los arbustales están dominados por *Vachellia caven* (nombre común: Espinillo) y presentan una cobertura del estrato arbustivo entre 25 y 65 %, con alturas que oscilan entre 2 y 4 m.

El área sobre la cual se ejecutó la clasificación de coberturas y uso de suelo, abarca un sector de las Sierras Chicas de 59.700 ha, cuyos límites son... . La misma incluye áreas urbanizadas y de interés, tales como Carlos Paz y alrededores, Malagueño, y el propio CETT ubicado en Falda del Cañete **(Figura X)**. 

$$$$$$$$$$$$$$$
**Figura X.**---

## 2.2. Recolección de datos de campo

El día 25 de junio del 2026 se realizó una recorrida por el Centro Espacial Teófilo Tabanera [CETT] (Falda del Cañete, Córdoba) con el fin de realizar una recolección de datos de referencia sobre el tipo de cobertura y vegetación sobre distintos puntos previamente definidos dentro del área del CETT. En total se referenciaron 12 puntos según 4 categorías: arbustal, bosque, pastizal y edificación/urbano.

## 2.3. Procesamiento de datos e imágenes satelitales

### 2.3.1. Datos de campo

A los datos de campo recolectados se les agregaron datos de puntos a los que previamente se les había asignado un tipo de cobertura y/o uso de suelo. De esta forma se contó con un total de 21 registros dentro del CETT para las clasificaciones posteriores. Las operaciones de geoprocesamiento necesarias para este paso se realizaron empleando el software QGIS.

### 2.3.2. Imágenes satelitales

Para la clasificación se han empleado dos escenas de Sentinel 2 (S8) con nivel de procesamiento 2, incluyendo las bandas 2 a 12. Una de ellas fue obtenida el día 6 de enero del año 2026, correspondiente a la época húmeda, mientras que la segunda fue obtenida el día 26 de mayo del mismo año, y se corresponde a la época seca. **(Figura X)**. Esta contenían el área de estudio previamente definida (ver ítem 2.1), por lo que posteriormente fueron clippeadas según los límites de la misma. 

A partir de estas imágenes se han generado 3 índices espectrales derivados: el Índice de Vegetación de Diferencia Normalizada (NDVI), el Índice Diferencial de Agua Normalizado (NDWI) y el Índice Urbano (UI) a partir del cómputo del algebra de bandas siguiendo las **Ecuaciones X, X, y X**, respectivamente.

$NDVI = \frac{NIR-Red}{NIR+Red}$ **Ecuación X**

$NDWI = \frac{Green-NIR}{Green-NIR}$ **Ecuación X**

$UI = \frac{SWIR2-RedEdge4}{SWIR2+RedEdge4}$ **Ecuación X**

Adicionalmente se empleó el producto de modelo digital de elevación (MDE) con resolución de 30 m de Shuttle Radar Topography Mission (SRTM). Finalmente, se creó un cubo de datos incluyendo las bandas 2-12 para las escenas de S2, los indices derivados y el MDE, a partir de su apilado. De esta forma, quedaron listos los datos clasificación y elaboración del mapa de coberturas y uso de suelo en el siguiente paso. 

La obtención y procesamiento de las imágenes de S2, así como la obtención de los indices espectrales derivados y el modelo de elevación, como la ejecución de geoprocesamiento, se han realizado a través del [editor de código de Google Earth Engine](https://code.earthengine.google.com/). De esta forma, todo el procesamiento se ejecutó en la nube, prescindiendo de recursos computacionales propios. Por otro lado, esto facilitó realizar tanto el procesamiento de los datos, así como la clasificación, en un flujo de trabajo unificado. 

## 2.4. Clasificación y evaluación de los resultados

La ejecución de la clasificación con la posterior elaboración de los mapas de coberturas en el área de estudio, se realizó empleando el modelo de clasificación *Random Forest*. 

![alt text](../images_report/fig01.png){ width=18% }
**Figura X**. ---

## 2.2. Procesamiento de los datos

Tanto la escena de L8, así como los archivos vectoriales fueron enteramente procesados mediante scripts desarrollados en Python. Las operaciones de algebra de bandas, stackeado de bandas, clipping, así cómo extracción de datos de reflectancia se realizaron empleando las librerías *numpy*, *rasterio*, *pandas* y *geopandas*. El ajuste del modelo semiempirico se realizó empleando la funcion *OLS* de *Stats Models*. Los códigos se encuentran públicos en el siguiente [repositorio de GitHub](https://github.com/francobarrionuevoenv21/MAIE_devs_pub/tree/main/Teledt_ambiental/TP2_Clorofila-a).

### 2.2.1. Actualización límites del Lago San Roque

Debido a las variaciones que puede sufrir el lago, como por ejemplo cambios en el su nivel, se han actualizado los límites del cuerpo de agua. Para ello se ha computado e índice Índice de Agua de Diferencia Normalizada Modificada (MNDWI) **(Ecuación X)** a partir de la escena de L8 adquirida el 22 de febrero del año 2017. Se han enmascarado los valores menores a 0, y finalmente se ha vectorizado el resultado

$MNDWI = \frac{Green-SWIR}{Green+SWIR}$ **Ecuacion X**

### 2.2.2. Datos de reflectancia y ajuste de un modelo semiempírico

Para cada de unos de los puntos de muestreo sobre los cuales se contaba con datos de medición en campo de la concentración de clorofila **(FIGURA X)**, se han extráido los valores de valores de reflectancia de la escena de L8 para las bandas 1 a 7. A partir de ellos, luego se elaboró un *feature* derivado a partir de la relación entre las bandas 5 y 4 (B5/B4). Empleando los datos de B5/B4 como variable explicativa y la concentración de clorofila medida en campo como variable explicada, se ajustó un modelo de regresión lineal. A partir de este modelo, luego se predijo la concentración de clorofila dentro del Lago San Roque a partir de relación entre las reflectancias de las bandas 5 y 4. 

# 3. Resultados

## 3.1. Actualización límites de Lago San Roque

La actualización de los límites del LSR empleando el índice MNDWI, dió cómo resultado un área levemente un poco menor al del original. De esta forma, se pasó de un área computada total de 20,18 $km^{2}$ a 19,69 $km^{2}$ **(FIGURA X)**. Si bien, no es posible concluir sobre si esta diferencia se debe a cambios en las condiciones físicas del lago, se garantiza que la predicción de la concentración de clorofila en el LSR se hará sobre la superficie de agua definida como aquella con $MDNWI > 0$ a partir de la escena de L8 utilizada.

![alt text](../images_report/fig03.png){ width=18% }
**Figura X**. ---

## 3.2. Datos ajuste del modelo

El ajuste del modelo semiempírico para la predicción de la concentración de clorofila en el LSR, como se ha mencionado, se ha realizado empleando los datos de reflectancia de Landsat 8 y los datos medidos en campo de la concetración de este microorganismo, ambos corresponden a mediciones realizadas la misma fecha. Se menciona que el dato del punto denominado como GAR (Garganta) fue excluido debido a que el pixel contiene una mayor proporción de suelo que de agua. Tal como se observa en la **FIGURA X (Derecha)**, la mayor concentración de clorofila se midió en los puntos *SAT2*, *CENT*, y *ZB*, destacándose este último con una concentración medida mayor a 250 $\mu$$g/L$.

La reflectancia medida en en la mayoría los sitios de muestreo presentaron firmas espectrales asimilables a la de la vegetación, con un pico en el rango del verde, un valle de alta absorción en la banda del rojo (B4) y un pico en la banda del NIR (B5). Se destacan la alta reflectancia relativa registrada en los sitios *SAT1*, *SAT2* y *ZB*. La excepción la cumple el punto *SAT3* que presenta una firma típica de agua **FIGURA X (Izquierda)**

En general, a modo de primer análisis de los resultados, se puede observar que los valores medidos tanto para la concentración de cianobacterias como la reflectancia guardan coherencia con lo esperado. Es decir, a mayor concentración de clorofila, debería aumentar la reflectancia y virar de una firma espectral de agua a una asimilable a vegetación. Este supuesto es que posteriormente se utilizó para ajustar el modelo semiempírico. 

![Figura 4](../images_report/fig04a.png){ width=60% }
**Figura X**. ---

## 3.3. Ajuste del modelo semiempírico

Habiendo recopilado tanto los datos de reflectancia como los de concentración de clorofila para los 7 puntos de muestreo, se prosiguió con el ajuste de un modelo lineal. Para ello se definió como variable predictora la relación entre las reflectancias en el rojo y el NIR, que definió como *B5/B4* según el número de banda de L8. La variable predicha fue el logaritmo de la concentración microorganismos, que es lo que sea conocer sobre toda la extensión del LSR. 

Se eligió un modelo de ajuste lineal, lo cual se realizó empleando la función de *OLS* de la librería *Stats Models* de Python. Primero, se ajustó un modelo preliminar incluyendo los datos de los 7 puntos de muestreo. Luego, análisis exploratorio mediante, se identificó como punto outlier al correspondiente a la estación *SAT 1*. De esta forma, se ajustó un segundo modelo que presentó un mejor coeficiente de determinación ($R^{2}$). Los modelos generados y los parámetros de cada uno se presentan en la **Figura X** y **Tabla X**, respectivamente.

![alt text](../images_report/fig5.png)
**Figura X**. ---

| Modelo | b | m | p-valor (m) | $R^{2}$ | Observación |
|:-------|------------:|--:|--:|--:|--------:|
| *M1* | 3.54 | 0.38 | 0.20 | 0.30 | Incluye los 7 ptos. de muestreo |
| *M2* | 3.82 | 0.33 | 0.17 | 0.41 | Excluye el sitio *SAT 1* |

**Tabla X**. ---

Tal como se puede observar en la tabla anterior, el segundo modelo presentó una mejora en el $R^{2}$. De todas maneras, en ninguno fue posible rechazar la hipótesis nula de la prueba para la pendiente de la recta, ya que en ambos se cumple que *p-valor > 0.05*. Bajo esta situación, se optó por utilizar el modelo 2 (M2) para la predicción de la concentración de clorofila en el LSR. A futuro se deben aumentar el número de puntos de muestreo para mejorar la confianza de los modelos a ajustar.  

## 3.4. Predicción de la concentración de clorofila

Empleando el modelo que quedó definido tal como se muestra en la **Ecuación 1**, se realizó la predicción de la concentración de clorofila en el LSR. Para ello se generó una matriz 2D de datos correspondientes a la relación entre las bandas *B5/B4*, la cual fue clippeada según los límites actualizados del lago (ver ítem 3.1). El resultado para cada pixel se computó como el $log(Conc. de clorofila)$ que posteriormente se convirtió a Conc. de clorofila mediante su función inversa. 

Debido a que el modelo ajustado solo es válido dentro del dominio en el cual fue ajustado, se definieron umbrales. Es decir en aquellos pixeles donde se que cumplía la relación *B5/B4 < 0.98* se le asignó la concentración mínima que devuelve el modelo. Mientras que para aquellos en los cuales se cumplía que la relación *B5/B4 > 4.11*, se le asignó el valor máximo. El resultado final, incluido este postprocesamiento, se muestra en el mapa de la **Figura X**. 

![alt text](../images_report/fig6.png)
**Figura X**. ---

Tal como se observa en la figura anterior, la concentración de clorofila predicha en el LSR estuvo en el rango entre los 63 y 182 $\mu$$g/L$. Si se compara con los valores medidos en los puntos de muestreo, se observa una subestimación. Esto se explica, entre otros factores, a las restricción que presentó el modelo elegido. Entre ellas el bajo $R^{2}$. De todas formas, los resultados obtenidos si lograron capturar el patrón observado en el anpalisis preliminar de los datos (ver ítem 3.2), donde la mayor concentración del pigmento se halla en el centro y su borde este. 

# Referencias

Cabido, M., Zeballos, S. R., Zak, M., Carranza, M. L., Giorgis, M. A., Cantero, J. J., & Acosta, A. T. 
R. (2018). Native woody vegetation in central Argentina: Classification of Chaco and Espinal 
forests. Applied Vegetation Science, 21(2), 298–311.  
Cabrera, A. L. (1976). Regiones fitogeográficas argentinas. Enciclopedia Argentina de Agricultura 
y Jardinería. Tomo II. Acme. 
Cingolani, A. M., Giorgis, M. A., Hoyos, L. E., & Cabido, M. (2022). La vegetación de las montañas 
de Córdoba (Argentina) a comienzos del siglo XXI: un mapa base para el ordenamiento 
territorial. Boletín de la Sociedad Argentina de Botánica, 57(1), 65–100. 
Giorgis, M. A., Cingolani, A. M., Chiarini, F., Chiapella, J., Barboza, G., Ariza Espinar, L., Morero, 
R., Gurvich, D. E., Tecco, P. A., Subils, R., & Cabido, M. (2011). Composición florística del 
Bosque Chaqueño Serrano de la provincia de Córdoba, Argentina. Kurtziana, 36(1), 9–43.  