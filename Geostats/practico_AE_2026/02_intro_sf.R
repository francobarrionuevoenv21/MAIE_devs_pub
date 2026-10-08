###############################################################################
# Práctico 2. Datos georreferenciados en R: leer, proyectar, guardar y mapear
#
# Presentación relacionada: Introducción (datos georreferenciados).
# Datos: datos/soja_geo.txt (monitor de rendimiento de un lote de soja,
#        coordenadas geográficas WGS 84).
#
# Pregunta: ¿qué necesita R para saber que un dato "está en algún lugar"?
# Al final del práctico deberían poder pasar una tabla con coordenadas a un
# objeto espacial, cambiarle el sistema de referencia y hacer un mapa.
###############################################################################

# ---- Paquetes del curso -----------------------------------------------------
# Se instalan una sola vez. Los que no estén se instalan desde CRAN.
paquetes_curso <- c(
  "sf",
  "stars",
  "terra",
  "spdep",
  "gstat",
  "ggplot2",
  "dplyr",
  "tidyr",
  "patchwork",
  "mapview",
  "rpart",
  "rpart.plot",
  "randomForest",
  "nlme",
  "FNN",
  "e1071",
  "car",
  "spData",
  "tmap",
  "tidymodels",
  "ranger",
  "spatialsample",
  "waywiser",
  "caret",
  "CAST",
  "scales",
  "MASS"
)
faltan <- setdiff(paquetes_curso, rownames(installed.packages()))
if (length(faltan) > 0)
  install.packages(faltan)

library(sf) # sf es el paquete encargado de trabajar con archivos vectoriales --> trabaja con dataframes
# archivos raster--> terra  y stars (para cubos de datos temporales)
library(ggplot2)

# ---- 1. Leer una tabla con coordenadas ---------------------------------------
soja <- read.table("datos/soja_geo.txt", header = TRUE)
head(soja)
summary(soja)

# x e y son longitud y latitud en grados. Para R, por ahora, son dos columnas
# numéricas más: no sabe que describen una posición.

# ---- 2. Convertir a objeto espacial (sf) -------------------------------------
# Hay que decirle qué columnas son las coordenadas y en qué sistema están.
# EPSG 4326 = WGS 84, coordenadas geográficas (grados).
soja_sf <- st_as_sf(soja, coords = c("x", "y"), crs = 4326) # todas las funciones de st empiezan con "st"
soja_sf
st_crs(soja_sf)$epsg

# ---- 3. Proyectar a coordenadas planas (UTM 20 Sur) ---------------------------
# Para calcular distancias en metros (vecindarios, semivariogramas, kriging)
# necesitamos coordenadas planas. El lote está a unos 62° de longitud oeste,
# dentro de la zona UTM 20 Sur (EPSG 32720).
soja_utm <- st_transform(soja_sf, crs = 32720)
st_bbox(soja_utm)

# Comparemos la distancia entre los dos primeros registros en cada sistema.
st_distance(soja_sf[1:2, ])    # sf calcula la distancia geodésica, en metros --> sf automaticamente reproyecta a utm (coord. planas) y calcula 
st_distance(soja_utm[1:2, ])   # distancia euclídea en el plano, en metros
sqrt(sum((
  st_coordinates(soja_sf)[1, ] - st_coordinates(soja_sf)[2, ]
)^2))
# La última es la "distancia" calculada a mano en grados: no tiene unidades
# útiles. Es el error que se comete si se usan longitud y latitud como si
# fueran x e y en un semivariograma.

# ---- 4. Guardar ---------------------------------------------------------------
# GeoPackage: un solo archivo, guarda el sistema de referencia y no recorta
# los nombres de las columnas (el shapefile sí).
st_write(soja_utm, "datos/soja_t.gpkg", append = FALSE)

# Si alguien necesita una planilla, se exportan las coordenadas como columnas.
dir.create("resultados", showWarnings = FALSE)
write.csv(cbind(st_drop_geometry(soja_utm), st_coordinates(soja_utm)),
          "resultados/soja_utm.csv",
          row.names = FALSE)

# Volver a leer
soja_utm <- st_read("datos/soja_t.gpkg")

# ---- 5. Mapas ----------------------------------------------------------------
# Mapa rápido con plot()
plot(
  soja_utm["REND"],
  pch = 20,
  cex = 0.3,
  key.pos = 4,
  axes = TRUE,
  main = "Rendimiento de soja (t/ha), datos crudos"
)

# Mapa con ggplot2. La escala de color importa: viridis es perceptualmente
# uniforme y se lee bien en blanco y negro y con daltonismo.
ggplot(soja_utm) +
  geom_sf(aes(colour = REND), size = 0.3) +
  scale_colour_viridis_c(option = "mako",
                         direction = -1,
                         name = "t/ha") +
  labs(title = "Rendimiento de soja, datos crudos") +
  theme_minimal()

# Hay valores extremos que aplastan la escala. Probemos limitarla a los
# percentiles 1 y 99 (no se borra nada, sólo cambia el color).
lim <- quantile(soja_utm$REND, c(0.01, 0.99))
ggplot(soja_utm) +
  geom_sf(aes(colour = REND), size = 0.3) +
  scale_colour_viridis_c(
    option = "mako",
    direction = -1,
    name = "t/ha",
    limits = lim,
    oob = scales::squish
  ) +
  theme_minimal()

# Mapa interactivo (abre en el visor de RStudio), útil para explorar
# mapview::mapview(soja_utm, zcol = "REND", cex = 2, lwd = 0)

# ---- Para discutir ------------------------------------------------------------
# 1. En el mapa con la escala limitada, ¿se ven patrones que no son del cultivo?
#    (pasadas de la cosechadora, cabeceras, franjas). Los vamos a tratar en el
#    práctico de análisis exploratorio.
# 2. ¿Qué pasaría con un semivariograma calculado en grados en un área de
#    500 km de norte a sur?
