###############################################################################
# Análisis Espacial - Clase 1
# Procesos aleatorios, realizaciones y dependencia espacial
#
# Dos preguntas:
#  1) ¿Qué significa que el mapa que observamos es "una realización" de un
#     proceso aleatorio?
#  2) ¿Qué pasa con un intervalo de confianza clásico para la media cuando
#     los datos están espacialmente autocorrelacionados?
###############################################################################

library(MASS)     # mvrnorm(): simular de una normal multivariada
library(ggplot2)

set.seed(2026)

# -----------------------------------------------------------------------------
# Función de covarianza exponencial
#   C(h) = sill * exp(-3 h / rango)
#   'rango' es el rango práctico: a esa distancia la correlación cae a ~0,05
# -----------------------------------------------------------------------------
cov_exponencial <- function(h, sill = 1, rango = 20) {
  sill * exp(-3 * h / rango)
}

###############################################################################
# PARTE 1. Varias realizaciones de un mismo proceso
###############################################################################

# Grilla de 40 x 40 celdas (por ejemplo, un lote o una región)
grilla <- expand.grid(x = 1:40, y = 1:40)

# Matriz de distancias entre todas las celdas y matriz de covarianzas
D <- as.matrix(dist(grilla))
Sigma <- cov_exponencial(D, sill = 1, rango = 20)

# Un proceso gaussiano estacionario observado en la grilla es una normal
# multivariada: misma media en todos los sitios y covarianza que depende
# sólo de la distancia.
media <- 10
n_sim <- 500
sims <- mvrnorm(n = n_sim,
                mu = rep(media, nrow(grilla)),
                Sigma = Sigma)
dim(sims)  # 500 realizaciones (filas) x 1600 sitios (columnas)

# Miramos cuatro realizaciones
cuatro <- do.call(rbind, lapply(1:4, function(i) {
  data.frame(grilla,
             z = sims[i, ],
             realizacion = paste("Realización", i))
}))

# Un sitio fijo x0 para seguirlo en todas las realizaciones
x0 <- data.frame(x = 12, y = 28)
id_x0 <- which(grilla$x == x0$x & grilla$y == x0$y)

p_realizaciones <- ggplot(cuatro, aes(x, y, fill = z)) +
  geom_raster() +
  geom_point(
    data = x0,
    aes(x, y),
    inherit.aes = FALSE,
    shape = 21,
    size = 3,
    fill = "white",
    stroke = 1.2
  ) +
  scale_fill_viridis_c(option = "mako",
                       direction = -1,
                       name = "Z(x)") +
  facet_wrap(~ realizacion, nrow = 2) +
  coord_equal() +
  theme_void(base_size = 13) +
  theme(strip.text = element_text(size = 13, margin = margin(b = 4)))
p_realizaciones

# Pregunta para discutir: ¿en qué se parecen los cuatro mapas y en qué no?
# (tamaño de las manchas, variabilidad, ubicación de los valores altos)

# Valores de Z(x0) en las 500 realizaciones: la distribución en un sitio
valores_x0 <- data.frame(z = sims[, id_x0])

p_x0 <- ggplot(valores_x0, aes(z)) +
  geom_histogram(bins = 30,
                 fill = "#1D5C63",
                 colour = "white") +
  labs(x = "Z(x0) en 500 realizaciones", y = "Frecuencia") +
  theme_minimal(base_size = 13)
p_x0

# -----------------------------------------------------------------------------
# Cada sitio tiene su propia distribución; el mapa es UNA realización
# Dibujamos, sobre la realización 1, la distribución de Z en algunos sitios
# y marcamos qué valor tomó Z en esa realización.
# -----------------------------------------------------------------------------
sitios_muestra <- data.frame(
  x = c(6, 18, 30, 10, 24, 36, 8, 20, 33, 15),
  y = c(33, 34, 32, 23, 25, 22, 10, 13, 9, 3)
)
sitios_muestra$id <- match(paste(sitios_muestra$x, sitios_muestra$y),
                           paste(grilla$x, grilla$y))
sitios_muestra$z_obs <- sims[1, sitios_muestra$id]   # valor en la realización 1

# Cada "montañita" es la densidad normal de Z(x) en ese sitio, dibujada en
# miniatura: el eje horizontal local va de media - 3 sd a media + 3 sd.
desvio <- 1
ancho <- 3.2    # ancho de cada curva en unidades del mapa
alto <- 4.5     # altura máxima de cada curva
z_eje <- seq(media - 3 * desvio, media + 3 * desvio, length.out = 60)
curvas <- do.call(rbind, lapply(seq_len(nrow(sitios_muestra)), function(i) {
  data.frame(
    sitio = i,
    xx = sitios_muestra$x[i] + (z_eje - media) / (3 * desvio) * ancho,
    yy = sitios_muestra$y[i] + dnorm(z_eje, media, desvio) / dnorm(0) * alto
  )
}))
sitios_muestra$x_obs <- sitios_muestra$x + (sitios_muestra$z_obs - media) / (3 * desvio) * ancho

p_montanias <- ggplot() +
  geom_raster(data = data.frame(grilla, z = sims[1, ]),
              aes(x, y, fill = z),
              alpha = 0.75) +
  scale_fill_viridis_c(option = "mako",
                       direction = -1,
                       name = "Z(x)") +
  geom_polygon(
    data = curvas,
    aes(xx, yy, group = sitio),
    fill = "white",
    colour = "#1F2A30",
    alpha = 0.9,
    linewidth = 0.5
  ) +
  geom_segment(
    data = sitios_muestra,
    aes(
      x = x - ancho,
      xend = x + ancho,
      y = y,
      yend = y
    ),
    colour = "#1F2A30",
    linewidth = 0.4
  ) +
  geom_point(
    data = sitios_muestra,
    aes(x_obs, y),
    colour = "#B4532A",
    size = 2.2
  ) +
  coord_equal(expand = FALSE) +
  labs(x = "Coordenada x", y = "Coordenada y") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())
p_montanias

# Lectura: en cada sitio Z(x) podría tomar muchos valores (la curva);
# el punto naranja es el valor que "salió" en esta realización. Los puntos
# cercanos caen en zonas parecidas de su curva: eso es la autocorrelación.

# En la práctica tenemos UNA sola realización (un solo mapa) y un dato por
# sitio. Para estimar media y covarianza promediamos en el espacio, no entre
# realizaciones: por eso necesitamos el supuesto de estacionariedad.

###############################################################################
# PARTE 2. ¿Cuánta información tienen n datos autocorrelacionados?
###############################################################################
# Simulamos n = 200 sitios al azar en un cuadrado de 100 x 100, calculamos el
# IC 95 % clásico para la media (media ± 1,96 s / sqrt(n)) y vemos con qué
# frecuencia contiene a la media verdadera (0), para distintos rangos.

n <- 200
n_rep <- 1000
rangos <- c(0, 10, 25, 50)   # rango 0 = datos independientes

sitios <- data.frame(x = runif(n, 0, 100), y = runif(n, 0, 100))
D_sitios <- as.matrix(dist(sitios))

cobertura <- sapply(rangos, function(r) {
  if (r == 0) {
    S <- diag(n)                               # sin dependencia espacial
  } else {
    S <- cov_exponencial(D_sitios, sill = 1, rango = r)
  }
  datos <- mvrnorm(n = n_rep,
                   mu = rep(0, n),
                   Sigma = S)
  contiene <- apply(datos, 1, function(z) {
    ic <- mean(z) + c(-1, 1) * 1.96 * sd(z) / sqrt(n)
    ic[1] < 0 & 0 < ic[2]
  })
  mean(contiene)
})

resultado <- data.frame(rango = rangos, cobertura = cobertura)
resultado

p_cobertura <- ggplot(resultado, aes(factor(rango), cobertura)) +
  geom_col(fill = "#1D5C63", width = 0.6) +
  geom_hline(yintercept = 0.95,
             linetype = "dashed",
             colour = "#B4532A") +
  geom_text(aes(label = scales::percent(cobertura, accuracy = 1)),
            vjust = -0.4,
            size = 4.5) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 1.05)) +
  labs(x = "Rango práctico de la autocorrelación (0 = independientes)", y = "Cobertura real del IC 95 %") +
  theme_minimal(base_size = 13)
p_cobertura

# Preguntas para discutir:
#  - ¿Por qué la cobertura cae al aumentar el rango?
#  - ¿Qué parte del IC está mal: la media estimada o su error estándar?
#  - ¿Qué implicaría esto para una prueba t o un ANOVA con datos espaciales?
