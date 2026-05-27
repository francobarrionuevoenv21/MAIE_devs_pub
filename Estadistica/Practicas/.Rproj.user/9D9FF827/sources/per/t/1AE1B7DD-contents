library(dplyr)
library(ggplot2)

## Read dataset
datos_ndvi <- read.table("datos/ndvi_p.txt")

## Display dataset head
head(datos_ndvi)

## Display rows and columns
dim(datos_ndvi)

##----------------- EJ 1.1.1_INTERVALOS DE CONFIANZA 95%, TODA EL ÁREA ---------

## ndvi whole area
ndvi <- datos_ndvi$ndvi

## Define alpha/2
alpha <- 5
alpha_2 <- (alpha/2)/100

## Define z using t student distribution
tIzq <- qt(alpha_2, length(ndvi)-1)
tDer <- qt((1-alpha_2), length(ndvi)-1)

## Compute mean value
xMean <- mean(ndvi) 

## Compute whole samples sd value
sd <- sd(ndvi)

## Compute interval 
min <- xMean + tIzq*sd/sqrt(length(ndvi))
max <- xMean + tDer*sd/sqrt(length(ndvi))

## Display results
print("Intervalo ndvi total")
print("Min: ")
print(min)
print("Max: ")
print(max)

##------- EJ 1.1.1_INTERVALOS DE CONFIANZA 90, 95 y 99%, AGRICOLA Y SIERRA------

## Filter data by "zona"
ndvi_agri <- datos_ndvi$ndvi[datos_ndvi$zona == "agricola"]
ndvi_sier <- datos_ndvi$ndvi[datos_ndvi$zona == "sierra"]

## ----- INTERVALO 90%

## Define alpha/2
alpha <- 10
alpha_2 <- (alpha/2)/100

## Define z using t student distribution
tIzq_agri <- qt(alpha_2, length(ndvi_agri)-1)
tDer_agri <- qt(1-alpha_2, length(ndvi_agri)-1)
tIzq_agri

tIzq_sier <- qt(alpha_2, length(ndvi_sier)-1)
tDer_sier <- qt(1-alpha_2, length(ndvi_sier)-1)

## Compute mean values
xMean_agri <- mean(ndvi_agri) 
xMean_sier <- mean(ndvi_sier)

## Compute samples sd values
sd_agri <- sd(ndvi_agri)
sd_sier <- sd(ndvi_sier)

## Compute min and max 
min_agri <- xMean_agri + tIzq_agri*sd_agri/sqrt(length(ndvi_agri))
max_agri <- xMean_agri + tDer_agri*sd_agri/sqrt(length(ndvi_agri))

min_sier <- xMean_sier + tIzq_sier*sd_sier/sqrt(length(ndvi_sier))
max_sier <- xMean_sier + tDer_sier*sd_sier/sqrt(length(ndvi_sier))

## Display results
print("Intervalo ndvi agrícola")
print("Min: ")
print(min_agri)
print("Max: ")
print(max_agri)
print("Precision")
print(max_agri-min_agri)

print("Intervalo ndvi sierra")
print("Min: ")
print(min_sier)
print("Max: ")
print(max_sier)
print("Precision")
print(max_sier-min_sier)

## ----- INTERVALO 95%

## Define alpha/2
alpha <- 5
alpha_2 <- (alpha/2)/100

## Define z using t student distribution
tIzq_agri <- qt(alpha_2, length(ndvi_agri)-1)
tDer_agri <- qt(1-alpha_2, length(ndvi_agri)-1)

tIzq_sier <- qt(alpha_2, length(ndvi_sier)-1)
tDer_sier <- qt(1-alpha_2, length(ndvi_sier)-1)

## Compute mean values
xMean_agri <- mean(ndvi_agri) 
xMean_sier <- mean(ndvi_sier)

## Compute samples sd values
sd_agri <- sd(ndvi_agri)
sd_sier <- sd(ndvi_sier)

## Compute min and max 
min_agri <- xMean_agri + tIzq_agri*sd_agri/sqrt(length(ndvi_agri))
max_agri <- xMean_agri + tDer_agri*sd_agri/sqrt(length(ndvi_agri))

min_sier <- xMean_sier + tIzq_sier*sd_sier/sqrt(length(ndvi_sier))
max_sier <- xMean_sier + tDer_sier*sd_sier/sqrt(length(ndvi_sier))

## Display results
print("Intervalo ndvi agrícola")
print("Min: ")
print(min_agri)
print("Max: ")
print(max_agri)
print("Precision")
print(max_agri-min_agri)

print("Intervalo ndvi sierra")
print("Min: ")
print(min_sier)
print("Max: ")
print(max_sier)
print("Precision")
print(max_sier-min_sier)

## ----- INTERVALO 99%

## Define alpha/2
alpha <- 1
alpha_2 <- (alpha/2)/100

## Define z using t student distribution
tIzq_agri <- qt(alpha_2, length(ndvi_agri)-1)
tDer_agri <- qt(1-alpha_2, length(ndvi_agri)-1)

tIzq_sier <- qt(alpha_2, length(ndvi_sier)-1)
tDer_sier <- qt(1-alpha_2, length(ndvi_sier)-1)

## Compute mean values
xMean_agri <- mean(ndvi_agri) 
xMean_sier <- mean(ndvi_sier)

## Compute samples sd values
sd_agri <- sd(ndvi_agri)
sd_sier <- sd(ndvi_sier)

## Compute min and max 
min_agri <- xMean_agri + tIzq_agri*sd_agri/sqrt(length(ndvi_agri))
max_agri <- xMean_agri + tDer_agri*sd_agri/sqrt(length(ndvi_agri))

min_sier <- xMean_sier + tIzq_sier*sd_sier/sqrt(length(ndvi_sier))
max_sier <- xMean_sier + tDer_sier*sd_sier/sqrt(length(ndvi_sier))

## Display results
print("Intervalo ndvi agrícola")
print("Min: ")
print(min_agri)
print("Max: ")
print(max_agri)
print("Precision")
print(max_agri-min_agri)

print("Intervalo ndvi sierra")
print("Min: ")
print(min_sier)
print("Max: ")
print(max_sier)
print("Precision")
print(max_sier-min_sier)

##----------------- EJ 1.1._IC VAR POB 95%, TODA EL ÁREA -----------------------

## Define alpha/2
alpha <- 5
alpha_2 <- (alpha/2)/100

n <- length(ndvi)
s2 <- var(ndvi)

chi_upper <- qchisq(1 - alpha_2, n - 1)
chi_lower <- qchisq(alpha_2, n - 1)
## chi_upper > chi_lower

lower <- ((n - 1) * s2) / chi_upper
upper <- ((n - 1) * s2) / chi_lower

c(lower, upper)

##----------------- EJ 2.1._Bolsas de café -------------------------------------

datos_cafe <- c(502, 501, 497, 491, 496, 501, 502, 500, 489, 490)

##****************************************************************************##
## 1) 95% interval
##****************************************************************************##

## Define alpha/2
alpha <- 5
alpha_2 <- (alpha/2)/100

## Define z using t student distribution
tLow <- qt(alpha_2, length(datos_cafe)-1)
tUpr <- qt(1-alpha_2, length(datos_cafe)-1)

## Compute mean values
datosMean <- mean(datos_cafe)

## Compute samples sd values
datosSD <- sd(datos_cafe)

## Compute min and max 
cafeLow <- datosMean + tLow*datosSD/sqrt(length(datos_cafe))
cafeUpr <- datosMean + tUpr*datosSD/sqrt(length(datos_cafe))

## Display results
c(cafeLow, cafeUpr) ## output: [1] 493.199 500.601

##****************************************************************************##
## 2&3) Propose hypothesis
## H0: μ = 500
## Ha: μ ≠ 500
##****************************************************************************##

mu <- 500

## Display statistics
c(tLow, tUpr) ## output: -2.262157  2.262157

## Compute observed statistics
tObs_cafe <- ((mean(datos_cafe)-mu)/(sd(datos_cafe)/sqrt(length(datos_cafe))))
tObs_cafe
## output: [1] -1.894805 --> Accept H0

## Try test with t.test()
t.test(datos_cafe, conf.level = 0.95)

##----------------- EJ 2.2._Quitamanchas ---------------------------------------

##****************************************************************************##
## Sampling proportion data
## n: 200
## Positive cases: 174

##  Propose hypothesis
## H0: p = 0.9
## Ha: p < 0.9
##****************************************************************************##  

n <- 200
pos <- 174
pProM <- pos/n
p <- 0.9

## Define alpha/2
alpha <- 5
alpha_n <- alpha/100

## Define z using t student distribution (ONE SIDED)
zLow <- qnorm(alpha_n)
zLow ## output: -1.644854

##
zObs<-(pProM-p)/sqrt(p*(1-p)/n)
zObs ## output: -1.414214 --> Accept H0

##----------------- EJ 2.3._Indice cardiaco ---------------------------------------

## Read dataset
datos_shock <- read.table("datos/Shock.csv", header=TRUE, sep=",")

## Display dataset head
head(datos_shock)

##****************************************************************************##
## 1&2) Descriptive statistis
##****************************************************************************##

## Descriptive statistics (grouped by shock type)
datos_shock %>%
  group_by(shock) %>%
  summarise(
    n = n(),
    media = mean(ic),
    varanza = var(ic),
    de = sd(ic),
    cv = sd(ic) / mean(ic) * 100, 
    EE = de / sqrt(n()),
    p05 = quantile(ic, 0.05),
    p25 = quantile(ic, 0.25),
    p50 = quantile(ic, 0.50),
    p75 = quantile(ic, 0.75),
    p95 = quantile(ic, 0.95),
  )

##****************************************************************************##
## 6) Hypothesis tests
## H0_ic: μ = 3
## Ha_ic: μ ≠ 3
##****************************************************************************##

t.test(datos_shock$ic, mu = 3)

##****************************************************************************##
## 7) Boxplot
##****************************************************************************##

boxplot(ic ~ shock, data = datos_shock, xlab = "Shock Type", ylab = "IC")

##****************************************************************************##
## 8) ANOVA shock type
##****************************************************************************##

aov(datos_shock, ic ~ shock)


##****************************************************************************##
## Sampling proportion data
## n: 200
## Positive cases: 174

##  Propose hypothesis
## H0: p = 0.9
## Ha: p < 0.9
##****************************************************************************##  

