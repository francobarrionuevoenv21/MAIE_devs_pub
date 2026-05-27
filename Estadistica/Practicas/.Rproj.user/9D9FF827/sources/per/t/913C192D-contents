## ----message=FALSE, echo = TRUE--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# install.packages("dplyr")
# install.packages("ggplot2")
library(dplyr)
library(ggplot2)


## ----echo = TRUE, message=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
datos_ndvi <- read.table("datos/ndvi_p.txt")

## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
head(datos_ndvi)

## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
dim(datos_ndvi)

## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class(datos_ndvi$ndvi)
class(datos_ndvi$zona)

## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
summary(datos_ndvi)

## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
table(datos_ndvi$zona)

## ----eval = !with_answer, echo = !with_answer------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# datos_ndvi %>%
#   summarise(
#     n = n(),
#     media = mean(ndvi)
#   )


## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
datos_ndvi %>%
  summarise(
    n = n(),
    media = mean(ndvi),
    varanza = var(ndvi),
    de = sd(ndvi),
    cv = sd(ndvi) / mean(ndvi) * 100,
    EE = de / sqrt(n()),
    p05 = quantile(ndvi, 0.05),
    p25 = quantile(ndvi, 0.25),
    p50 = quantile(ndvi, 0.50),
    p75 = quantile(ndvi, 0.75),
    p95 = quantile(ndvi, 0.95),
    iqr = IQR(ndvi)
  )

## ----message=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ggplot(datos_ndvi, aes(x = ndvi)) +
  geom_histogram(bins = 35) +
  ylab("Frecuencia absoluta") +
  xlab("NDVI")

## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ggplot(datos_ndvi, aes(x = ndvi)) +
  geom_density() +
  ylab("Frecuencia absoluta") +
  xlab("NDVI")

## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ggplot(datos_ndvi, aes(x = ndvi)) +
  stat_ecdf() +
  ylab("Frecuencia relativa acumulada") +
  xlab("NDVI")

## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ggplot(datos_ndvi, aes(y = ndvi)) +
  geom_boxplot()

## ----eval = !with_answer, echo = !with_answer------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# datos_ndvi %>%
#   group_by(zona) %>%
#   summarise(
#     n = n(),
#     media = mean(ndvi)
#   )


## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
datos_ndvi %>%
  group_by(zona) %>%
  summarise(
    n = n(),
    media = mean(ndvi),
    varanza = var(ndvi),
    de = sd(ndvi),
    cv = sd(ndvi) / mean(ndvi) * 100, 
    EE = de / sqrt(n()),
    p05 = quantile(ndvi, 0.05),
    p25 = quantile(ndvi, 0.25),
    p50 = quantile(ndvi, 0.50),
    p75 = quantile(ndvi, 0.75),
    p95 = quantile(ndvi, 0.95),
    iqr = IQR(ndvi)
  )


## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ggplot(datos_ndvi, aes(x = ndvi, color = zona)) +
  stat_ecdf() +
  ylab("Frecuencia relativa acumulada") +
  xlab("NDVI")

## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ggplot(datos_ndvi, aes(y = ndvi, x = zona)) +
  geom_boxplot()


## --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EE <- function(x) {
  sd(x, na.rm = TRUE) / sqrt(length(complete.cases(x)))
}

ggplot(data = datos_ndvi) +
  stat_summary(
    aes(x = zona, y = ndvi),
    fun.min = function(x) {
      mean(x) - EE(x)
    },
    fun.max = function(x) {
      mean(x) + EE(x)
    },
    fun = mean
  ) +
  ylab("NDVI") +
  xlab("Zona")


## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ggplot(data = datos_ndvi, aes(x = zona, y = ndvi)) +
  stat_summary(
    fun.data = mean_se
  ) +
  ylab("NDVI") +
  xlab("Zona")


## ----satelites, eval = with_answer, echo = with_answer---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
satelites <- read.table("datos/Satelites_2022.txt", header = TRUE)

mean(satelites$SatelitesOrbita)
median(satelites$SatelitesOrbita)

# hist(satelites$SatelitesOrbita)
ggplot(satelites, aes(SatelitesOrbita)) +
  geom_histogram()

# La mediana es un mejor indicador de la distribución de satélites, dado que
# es una variable muy asimétrica (derecha) y la media no es un valor que
# represente bien a la mayoría de los datos.

sum(satelites$SatelitesOrbita)


## ----eval = with_answer, echo = with_answer--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
pp <- read.table("datos/precipitacionesCuenca.txt", sep = ";", header = TRUE)

# hist(pp$Pp.media.anual)
# ggplot(pp, aes(Pp.media.anual)) +
#   geom_histogram()

## display dataset head
head(pp)
  
pp %>%
  summarise(
    n = n(),
    media = mean(Pp.media.anual),
    mediana = quantile(Pp.media.anual, 0.50),
    rango = max(Pp.media.anual) - min(Pp.media.anual),
    p25 = quantile(Pp.media.anual, 0.25),
    p75 = quantile(Pp.media.anual, 0.75),
    recorridoIQ = IQR(Pp.media.anual)
  )

# plot(pp$Altura.msnm, pp$Pp.media.anual)
ggplot(pp, aes(Altura.msnm, Pp.media.anual)) +
  geom_point()


## ----mosquitos, eval = with_answer, echo = with_answer---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
mosquitos <-
  read.table(
    "datos/mosquitos_formosa.txt",
    sep = "\t",
    header = TRUE,
    encoding = 'latin1'
  )

nrow(mosquitos)
table(mosquitos$anio)
table(mosquitos$estacion)
class(mosquitos$casas.positivas)

mosquitos$prob <- mosquitos$casas.positivas / mosquitos$total

# hist(mosquitos$prob)
ggplot(mosquitos, aes(prob)) +
  geom_histogram()

ggplot(mosquitos, aes(estacion, prob)) +
  stat_summary(fun.data = mean_se, geom = "errorbar") +
  stat_summary(fun = mean, geom = "bar")


ggplot(mosquitos, aes(as.factor(anio), prob)) +
  stat_summary(fun.data = mean_se, geom = "errorbar") +
  stat_summary(fun = mean, geom = "bar")

# ggplot(mosquitos, aes(estacion, prob)) +
#   stat_summary(fun.data = mean_se, geom = "errorbar") +
#   stat_summary(fun = mean, geom = "bar") +
#   facet_grid(zona ~ anio)


