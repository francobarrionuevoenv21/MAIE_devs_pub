###############################################################################
# Práctico 2b. Mapas en R: ggplot2 y tmap
#
# Presentación relacionada: Introducción (tipos de datos espaciales).
# Datos: datos/soja_t.gpkg (rendimiento de soja; sale del práctico 2)
#        datos/MO_Córdoba.txt y datos/limites_cba/ (MO, escala provincial)
#        datos/grilla_MO.txt (covariables en una grilla de 500 m)
#
# Pregunta: ¿cómo mostramos cada tipo de dato espacial (puntos, áreas, grilla)
# para que el mapa diga lo que los datos dicen, y no otra cosa?
#
# Hacemos los mismos mapas con dos paquetes:
#   ggplot2: la gramática de gráficos de siempre; geom_sf() para objetos sf.
#   tmap (versión 4): pensado para mapas; trae escalas, leyendas, norte, barra
#        de escala y modo interactivo. La sintaxis de la versión 4 es distinta
#        de la 3: si encuentran ejemplos con tm_shape() + tm_dots(col = ...),
#        son de la versión vieja (ver https://r-tmap.github.io/tmap/).
###############################################################################

#install.packages("tmap")

library(sf)
library(stars)
library(ggplot2)
library(tmap) # versión 4 o posterior: packageVersion("tmap")
library(patchwork)

packageVersion("tmap")

soja <- st_read("datos/soja_t.gpkg", quiet = TRUE)
mo <- read.table("datos/MO_Córdoba.txt", header = TRUE) |>
  st_as_sf(coords = c("x", "y"), crs = 22174)
limite <- st_read("datos/limites_cba/Cordoba_limite.shp", quiet = TRUE) |>
  st_transform(22174)

# ==============================================================================
# 1. Puntos: rendimiento de soja en un lote
# ==============================================================================
# El color representa el valor. Una escala secuencial (de claro a oscuro) es
# la adecuada para una variable que va de poco a mucho.

# ---- ggplot2 -------------------------------------------------------------------
ggplot(soja) +
  geom_sf(aes(colour = REND), size = 0.3) +
  scale_colour_viridis_c(option = "mako", direction = -1, name = "t/ha") +
  labs(title = "Rendimiento de soja (datos crudos)") +
  theme_minimal()

# ---- tmap ----------------------------------------------------------------------
# Cada capa empieza con tm_shape(datos). En la versión 4 el color de relleno
# es "fill" y la escala se define con tm_scale_*().
tm_shape(soja) +
  tm_dots(
    fill = "REND",
    size = 0.1,
    fill.scale = tm_scale_continuous(values = "-seaborn.mako"),
    fill.legend = tm_legend(title = "t/ha")
  ) +
  tm_title("Rendimiento de soja (datos crudos)")

# Los dos mapas tienen el mismo problema: unos pocos valores extremos (hasta
# más de 600 t/ha) se llevan toda la escala y el resto del lote queda de un
# solo color. Limitamos la escala a los percentiles 1 y 99. No se borra ningún
# dato: los valores de afuera toman el color del extremo.
lim <- quantile(soja$REND, c(0.01, 0.99))
lim

ggplot(soja) +
  geom_sf(aes(colour = REND), size = 0.3) +
  scale_colour_viridis_c(
    option = "mako",
    direction = -1,
    limits = lim,
    oob = scales::squish,
    name = "t/ha"
  ) +
  theme_minimal()

tm_shape(soja) +
  tm_dots(
    fill = "REND",
    size = 0.1,
    fill.scale = tm_scale_continuous(
      values = "-seaborn.mako",
      limits = lim,
      outliers.trunc = c(TRUE, TRUE)
    ),
    fill.legend = tm_legend(title = "t/ha")
  )

# ==============================================================================
# 2. Puntos sobre un polígono, con elementos de mapa
# ==============================================================================
# MO en 340 sitios de la provincia. El límite da el contexto.

# ---- ggplot2 -------------------------------------------------------------------
# geom_sf() con varias capas: cada una con sus datos. El norte y la barra de
# escala no vienen con ggplot2 (están en el paquete ggspatial).
mapa_gg <- ggplot() +
  geom_sf(data = limite, fill = "grey95", colour = "grey40") +
  geom_sf(data = mo, aes(colour = MO), size = 1.8) +
  scale_colour_viridis_c(option = "mako", direction = -1, name = "MO (%)") +
  labs(title = "ggplot2") +
  theme_void()
mapa_gg

# ---- tmap ----------------------------------------------------------------------
mapa_tm <- tm_shape(limite) +
  tm_polygons(fill = "grey95", col = "grey40") +
  tm_shape(mo) +
  tm_dots(
    fill = "MO",
    size = 0.4,
    fill.scale = tm_scale_continuous(values = "-seaborn.mako"),
    fill.legend = tm_legend(title = "MO (%)")
  ) +
  tm_compass(position = c("left", "top")) +
  tm_scalebar(position = c("left", "bottom")) +
  tm_title("tmap")
mapa_tm

# Pregunta: ¿qué tienen que mostrar sí o sí estos mapas para que alguien que no
# conoce la provincia los entienda? ¿El norte y la escala aportan algo en un
# mapa de un lote? ¿Y en uno de la provincia?

# ==============================================================================
# 3. Grilla (raster): covariables de la provincia
# ==============================================================================
# grilla_MO.txt es una tabla con x, y y las covariables en una grilla de unos
# 500 m. La pasamos a un objeto stars (raster) de 1 km para que sea liviana.
grilla_tabla <- read.table("datos/grilla_MO.txt", header = TRUE) # tarda unos segundos
grilla <- grilla_tabla[, c("x", "y", "NDVI", "Altura", "PPmed")] |>
  st_as_sf(coords = c("x", "y"), crs = 22174) |>
  st_rasterize(dx = 1000, dy = 1000)
grilla

# ---- ggplot2 -------------------------------------------------------------------
# geom_stars() dibuja el objeto stars. Para una sola variable se elige con [ ].
ggplot() +
  geom_stars(data = grilla["Altura"]) +
  scale_fill_viridis_c(option = "rocket", direction = -1, na.value = NA, name = "m") +
  geom_sf(data = limite, fill = NA, colour = "grey30") +
  coord_sf() +
  labs(title = "Altura") +
  theme_void()

# ---- tmap ----------------------------------------------------------------------
tm_shape(grilla) +
  tm_raster(
    col = "Altura",
    col.scale = tm_scale_continuous(values = "-seaborn.rocket"),
    col.legend = tm_legend(title = "m")
  ) +
  tm_shape(limite) +
  tm_borders(col = "grey30") +
  tm_title("Altura")

# ---- Varias variables a la vez --------------------------------------------------
# Cada variable tiene sus unidades, así que cada una necesita su propia escala.
# En tmap alcanza con pedir varias columnas: por defecto cada panel tiene su
# escala y su leyenda.
tm_shape(grilla) +
  tm_raster(
    col = c("NDVI", "Altura", "PPmed"),
    col.scale = tm_scale_continuous(values = "-seaborn.mako")
  ) +
  tm_layout(panel.labels = c("NDVI", "Altura (m)", "Precipitación media (mm)"))

# En ggplot2, con facet_wrap() la escala de color es una sola para todos los
# paneles. Para escalas distintas se hacen mapas separados y se unen con
# patchwork.
mapa_variable <- function(variable, titulo) {
  ggplot() +
    geom_stars(data = grilla[variable]) +
    scale_fill_viridis_c(option = "mako", direction = -1, na.value = NA, name = NULL) +
    coord_sf() +
    labs(title = titulo) +
    theme_void()
}
mapa_variable("NDVI", "NDVI") +
  mapa_variable("Altura", "Altura (m)") +
  mapa_variable("PPmed", "Precipitación media (mm)")

# ==============================================================================
# 4. Áreas: la MO promedio en hexágonos, y cómo se eligen las clases
# ==============================================================================
# Armamos datos de área a partir de los puntos: promedio de la MO en hexágonos
# de unos 40 km. (En datos de área reales las unidades vienen dadas:
# departamentos, radios censales, cuencas.)
hexagonos <- st_make_grid(limite, cellsize = 40000, square = FALSE) |>
  st_as_sf() |>
  st_filter(limite)
hexagonos$MO <- sapply(st_intersects(hexagonos, mo), function(i) mean(mo$MO[i]))
hexagonos <- hexagonos[!is.na(hexagonos$MO), ]

# El mismo dato con tres escalas: continua, cinco intervalos iguales y cinco
# cuantiles (cada clase con la misma cantidad de hexágonos).
tm_shape(hexagonos) +
  tm_polygons(
    fill = c("MO", "MO", "MO"),
    fill.scale = list(
      tm_scale_continuous(values = "-seaborn.mako"),
      tm_scale_intervals(style = "equal", n = 5, values = "-seaborn.mako"),
      tm_scale_intervals(style = "quantile", n = 5, values = "-seaborn.mako")
    ),
    fill.legend = tm_legend(title = "MO (%)"),
    col = "white"
  ) +
  tm_layout(panel.labels = c("Continua", "Intervalos iguales", "Cuantiles"))

# En ggplot2, las clases se arman con scale_fill_binned() (o viridis_b) y los
# cortes se calculan aparte.
cortes_iguales <- seq(min(hexagonos$MO), max(hexagonos$MO), length.out = 6)
cortes_cuantiles <- unname(quantile(hexagonos$MO, seq(0, 1, 0.2)))
mapa_clases <- function(cortes, titulo) {
  ggplot(hexagonos) +
    geom_sf(aes(fill = MO), colour = "white") +
    scale_fill_viridis_b(
      option = "mako",
      direction = -1,
      breaks = round(cortes[-c(1, length(cortes))], 2),
      limits = range(cortes),
      name = "MO (%)"
    ) +
    labs(title = titulo) +
    theme_void()
}
mapa_clases(cortes_iguales, "Intervalos iguales") +
  mapa_clases(cortes_cuantiles, "Cuantiles")

# Pregunta: ¿cuál de los tres mapas haría pensar que "casi toda la provincia
# tiene MO baja"? ¿Y cuál que "la MO está repartida en partes iguales"? El dato
# es el mismo.

# ==============================================================================
# 5. Mapas interactivos y guardar
# ==============================================================================
# tmap tiene dos modos con el mismo código: "plot" (estático) y "view"
# (interactivo, sobre un mapa de fondo). Para volver: tmap_mode("plot").
tmap_mode("view")
mapa_tm
tmap_mode("plot")

# Guardar
dir.create("resultados", showWarnings = FALSE)
ggsave("resultados/mapa_MO_ggplot.png", mapa_gg, width = 5, height = 6, dpi = 300)
tmap_save(mapa_tm, "resultados/mapa_MO_tmap.png", width = 5, height = 6, dpi = 300)
tmap_save(mapa_tm, "resultados/mapa_MO_tmap.html") # versión interactiva

# ---- Para discutir --------------------------------------------------------------
# 1. ¿Para qué tipo de mapa usarían cada paquete? ggplot2 se combina con
#    cualquier otro gráfico (histogramas, semivariogramas) con la misma
#    sintaxis; tmap trae resueltas las cosas propias de un mapa.
# 2. En el mapa de soja, ¿qué patrón aparece recién al limitar la escala? ¿Es
#    del cultivo o de la cosechadora? (lo vemos en el práctico 3)
# 3. En la sección 4, ¿qué escala usarían para mostrar dónde hay MO alta? ¿Y
#    para comparar con otro año o con otra provincia?
# 4. Los hexágonos con un solo sitio tienen el mismo peso visual que los que
#    tienen diez. ¿Cómo lo mostrarían?
