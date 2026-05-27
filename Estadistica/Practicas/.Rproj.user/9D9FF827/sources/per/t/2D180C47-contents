##****************************************************************************##
## 1. Oxígeno disuelto
"
El archivo oxigeno_disuelto.txt contiente datos de muestreos de calidad de agua de la Red de
Intercambio de Información de los Gobiernos Locales (RIIGLO). Durante el año 2019 se registró el
valor medido de oxígeno disuelto (mg/l) en muestras tomadas, en sitios elegidos al azar, a lo largo
de la franja costera del Río de la Plata.
1.1. Objetivo
Determinar si el valor promedio de oxígeno disuelto cambia según la época del año.
1.2. Actividades
1. Realice una exploración gráfica de los datos.
2. Plantee las hipótesis del ANAVA.
3. Ajuste el modelo.
4. Controle los supuestos.
5. Interprete los resultados.
6. En caso necesario, compare medias.
"
##****************************************************************************##

data_oxd <- read.table("datos/oxigeno_disuelto.txt", header=TRUE)

head(data_oxd)

##----------------- Exploración gráfica de los datos ---------------------------

boxplot(od ~ epoca, 
        data = data_oxd, 
        xlab = "Dissolved oxygen", 
        ylab = "Season")

data_oxd %>%
  group_by(epoca) %>%
  summarise(
    n = n(),
    media = mean(od),
    varanza = var(od),
    de = sd(od),
    cv = sd(od) / mean(od) * 100, 
    EE = de / sqrt(n()),
    p05 = quantile(od, 0.05),
    p25 = quantile(od, 0.25),
    p50 = quantile(od, 0.50),
    p75 = quantile(od, 0.75),
    p95 = quantile(od, 0.95),
  )

##----------------- Hipothesis y ajuste modelo ---------------------------------
## hypothesis
## H0: μ_oto = μ_prim = μ_ver
## Ha: μ_oto ≠ μ_prim ≠ μ_ver
##------------------------------------------------------------------------------

fit <- aov(data_oxd$od ~ data_oxd$epoca)
summary(fit)

##------------------------------------------------------------------------------

"
OUTPUT:
Df Sum Sq Mean Sq F value Pr(>F)  
data_oxd$epoca   2   42.7  21.340   4.577 0.0124 *
  Residuals      106  494.3   4.663                 
---
  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Conlussion --> Reject H0

"

##----------------------- Tukey test (comparación de medias) -------------------

TukeyHSD(fit)
plot(TukeyHSD(fit))

##------------------------------------------------------------------------------

"
OUTPUT:
  Tukey multiple comparisons of means
    95% family-wise confidence level

Fit: aov(formula = data_oxd$od ~ data_oxd$epoca)

$`data_oxd$epoca`
                        diff       lwr         upr     p adj
primavera-otono  -1.28575415 -2.490112 -0.08139625 0.0334760
verano-otono     -1.32320513 -2.509556 -0.13685474 0.0248772
verano-primavera -0.03745098 -1.264959  1.19005667 0.9971044

Conlussion --> La media del otoño es significativamente diferente a las medias
de primavera y verano con un 95% de nivel de confianza
"

##------------------------------------------------------------------------------

##-------- Homogeneidad de varianzas de los residuos ---------------------------


##-------- Plot residuos

plot(fitted.values(fit), rstandard(fit),
     xlab = "Valores predichos", ylab = "Residuos estandarizados")


##-------- Test de Levene

## install.packages("lawstat")
library(lawstat)
levene.test(data_oxd$od, data_oxd$epoca,location = "mean")

##------------------------------------------------------------------------------

"
OUTPUT:
Classical Levene's test based on the absolute deviations from the mean (
	none not applied because the location is not set to median )

data:  data_oxd$od
Test Statistic = 1.1005, p-value = 0.3365

Conlussion --> Se comprueba H0, las varianzas son iguales
"

##------------------------------------------------------------------------------


##-------- Normalidad de los residuos ------------------------------------------

##-------- QQ plot

qqnorm(rstandard(fit))
qqline(rstandard(fit))

##-------- Shapiro test

shapiro.test(rstandard(fit))

##------------------------------------------------------------------------------

"
OUTPUT:
	Shapiro-Wilk normality test

data:  rstandard(fit)
W = 0.98173, p-value = 0.1408

Conlussion --> Se comprueba H0, los residuos tienen una distribución normal
"

##------------------------------------------------------------------------------

##****************************************************************************##
## 2. Porotos
"
2.1. Datos
T1: 76, 85, 74, 78, 82, 75, 82
T2: 57, 67, 55, 64, 61, 63, 63

2.2. Objetivo
Evaluar si existen diferencias entre los tiempos promedio de cocción.

2.3. Interpretación
Valor-p del ANAVA
¿Se rechaza 𝐻0?
Tratamiento con menor tiempo promedio
"
##****************************************************************************##

## Data
T1 <- c(76, 85, 74, 78, 82, 75, 82)
T2 <- c(57, 67, 55, 64, 61, 63, 63)

t_tot <- c(76, 85, 74, 78, 82, 75, 82, 57, 67, 55, 64, 61, 63, 63)
t_lab <- c("t1", "t1", "t1", "t1", "t1", "t1", "t1", "t2", "t2", "t2", "t2", "t2", "t2", "t2")

## Plot data (boxplot by group)
library(ggplot2)

df <- data.frame(tiempo = t_tot, tratamiento = t_lab)

ggplot(df, aes(x = tratamiento, y = tiempo)) +
  geom_boxplot() +
  labs(x = "Tratamiento", y = "Tiempo total")

##--------------- ANOVA --------------------------------------------------------
fit <- aov(t_tot ~ t_lab)
summary(fit)

##------------------------------------------------------------------------------

"
OUTPUT:
            Df Sum Sq Mean Sq F value   Pr(>F)    
t_lab        1 1063.1  1063.1   61.17 4.74e-06 ***
Residuals   12  208.6    17.4                     
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Conlussion --> Reject H0
"

##------------------------------------------------------------------------------


##-------- Homogeneidad de varianzas de los residuos ---------------------------


##-------- Plot residuos

plot(fitted.values(fit), rstandard(fit),
     xlab = "Valores predichos", ylab = "Residuos estandarizados")


##-------- Test de Levene

## install.packages("lawstat")
levene.test(data_oxd$od, data_oxd$epoca,location = "mean")

##------------------------------------------------------------------------------

"
OUTPUT:
Classical Levene's test based on the absolute deviations from the mean ( none
not applied because the location is not set to median )

data:  data_oxd$od
Test Statistic = 1.1005, p-value = 0.3365

Conlussion --> Se comprueba H0, las varianzas son iguales
"

##------------------------------------------------------------------------------

##-------- Normalidad de los residuos ------------------------------------------

##-------- QQ plot

qqnorm(rstandard(fit))
qqline(rstandard(fit))

##-------- Shapiro test

shapiro.test(rstandard(fit))

##------------------------------------------------------------------------------

"
OUTPUT:
	Shapiro-Wilk normality test

data:  rstandard(fit)
W = 0.95095, p-value = 0.5756

Conlussion --> No se rechaza H0, los residuos tienen una distribución normal
"

##------------------------------------------------------------------------------


##****************************************************************************##
## 3. NDVI Estaciones
"
Durante el año 2020 y para cada una de las estaciones del año se registró el valor promedio de NDVI
de puntos tomados al azar pertenecientes a zonas agrícolas. Los datos se encuentran en el archivo
ndvi_estaciones.txt.

3.1. Objetivo
Evaluar si el promedio de NDVI difiere entre estaciones del año e identificar qué estaciones presentan
mayores valores.

3.2. Actividades
1. Ajuste un ANAVA. Especifique el modelo y los supuestos del análisis.
2. Controle los supuestos.
3. Interprete el contraste global.
4. Compare medias si corresponde.
"
##****************************************************************************##

## Open data as a table
data_ndvi <- read.table("datos/ndvi_4_estaciones.txt")

## Display table head
head(data_ndvi)


