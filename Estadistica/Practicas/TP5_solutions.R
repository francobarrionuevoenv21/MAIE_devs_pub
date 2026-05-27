##****************************************************************************##
## 1. Agua
"
El archivo Agua.txt contiene datos de disponibilidad de agua en un cultivo de soja en los distintos
perfiles del suelo hasta una profundidad de 60 cm a los 100 días desde la emergencia. Los valores
de profundidad corresponden a 10, 20, 30, 40, 50 y 60 cm. Para cada profundidad existen tres
repeticiones correspondientes a distintos puntos de muestreo.
1.1. Objetivo
Evaluar cómo cambia el contenido de agua con la profundidad del suelo.
1.2. Actividades
1. Realice un diagrama de dispersión para explorar el comportamiento de ambas variables.
2. Ajuste un modelo lineal y a partir de los coeficientes estimados por el modelo, especifique la
ecuación ajustada.
3. Interprete los valores de los coeficientes estimados.
4. ¿Qué porcentaje de la variabilidad total observada en el contenido de agua del suelo es explicada
por la profundidad?
5. Prediga el contenido de agua para 25 y 30 cm.
"
##****************************************************************************##

## Read data
data_agua <- read.table("datos/Agua.txt", header=TRUE, sep="")##, encoding='latin1')

## Display table
head(data_agua)

## Store columns in different values
prof <- data_agua[,1]
agua <- data_agua[,2]

## Fit a linear regression model
modelo <- lm(agua ~ prof)
summary(modelo)

##------------------------------------------------------------------------------

"
OUTPUT:
Residuals:
    Min      1Q  Median      3Q     Max 
-3.4279 -0.8215  0.2473  1.2797  2.9226 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) 32.82707    0.99243   33.08 3.68e-16 ***
prof        -0.31102    0.02548  -12.21 1.61e-09 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 1.846 on 16 degrees of freedom
Multiple R-squared:  0.903,	Adjusted R-squared:  0.8969 
F-statistic:   149 on 1 and 16 DF,  p-value: 1.61e-09
"

##------------------------------------------------------------------------------

## Plot data
plot(prof, agua)
abline(coef(modelo))

## Predict values
x1 <- 25
x2 <- 30

y1 <- coef(modelo)[2]*x1 + coef(modelo)[1]
y2 <- coef(modelo)[2]*x2 + coef(modelo)[1]

c(y1, y2)

##****************************************************************************##
## 1. Salinidad y Biomasa
"
El archivo salinidad.txt contiene datos que corresponden a la medición de la producción de biomasa de
una forrajera (medido en gr) y a valores de propiedades químicas del suelo (pH, salinidad, contenido
de zinc (Zn) y contenido de potasio (K)) donde crecieron las plantas. Se desea modelar la producción
de biomasa en función de las propiedades químicas del suelo.

"
##****************************************************************************##

data_sal <- read.table("datos/Salinidad.txt", head=TRUE)

## Display data head
head(data_sal)

## Define model
model <- lm(Biomasa ~ pH + Salinidad + Zinc + Potasio, data = data_sal)

## Model summary
summary(model)

##------------------------------------------------------------------------------

"
OUTPUT:
Call:
lm(formula = Biomasa ~ pH + Salinidad + Zinc + Potasio, data = data_sal)

Residuals:
    Min      1Q  Median      3Q     Max 
-293.98  -88.83   -9.48   88.20  387.27 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 1492.8076   453.6013   3.291 0.002091 ** 
pH           262.8829    33.7304   7.794 1.51e-09 ***
Salinidad    -33.4997     8.6525  -3.872 0.000391 ***
Zinc         -28.9727     5.6643  -5.115 8.20e-06 ***
Potasio       -0.1150     0.0819  -1.404 0.167979    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 158.9 on 40 degrees of freedom
Multiple R-squared:  0.9231,	Adjusted R-squared:  0.9154 
F-statistic:   120 on 4 and 40 DF,  p-value: < 2.2e-16
"

##------------------------------------------------------------------------------

## Display correlation between variables
install.packages("GGally")
install.packages("ggplot2")

library(GGally)

ggpairs(
  data_sal
)

## 
# Standardized residuals
res <- rstandard(model)

# Select predictor variables
X <- data_sal[, c("pH", "Salinidad", "Zinc", "Potasio")]

# Define plot layout
par(mfrow = c(2,2))

# Loop through predictors
for(i in names(X)) {
  
  plot(X[[i]], res,
       xlab = i,
       ylab = "Residuos estandarizados",
       main = paste("Residuos vs", i))
  
  abline(h = 0, col = "red")
}

##------------------------------------------------------------------------------

## Define new model
model_2 <- lm(Biomasa ~ pH + Salinidad + I(Salinidad^2) + Zinc + Potasio, data = data_sal)

## Model summary
summary(model_2)

##------------------------------------------------------------------------------

"
Call:
lm(formula = Biomasa ~ pH + Salinidad + I(Salinidad^2) + Zinc + 
    Potasio, data = data_sal)

Residuals:
     Min       1Q   Median       3Q      Max 
-177.614  -75.127   -1.021   43.825  234.521 

Coefficients:
                 Estimate Std. Error t value Pr(>|t|)    
(Intercept)     1.043e+04  1.327e+03   7.860 1.46e-09 ***
pH              2.240e+02  2.356e+01   9.509 1.04e-11 ***
Salinidad      -5.905e+02  8.066e+01  -7.320 7.81e-09 ***
I(Salinidad^2)  8.902e+00  1.286e+00   6.923 2.73e-08 ***
Zinc           -3.639e+01  3.989e+00  -9.123 3.22e-11 ***
Potasio        -1.697e-01  5.611e-02  -3.023   0.0044 ** 
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 107.8 on 39 degrees of freedom
Multiple R-squared:  0.9655,	Adjusted R-squared:  0.9611 
F-statistic: 218.3 on 5 and 39 DF,  p-value: < 2.2e-16
"

##------------------------------------------------------------------------------

# Standardized residuals
res_2 <- rstandard(model_2)

# Select predictor variables
X_2 <- data_sal[, c("pH", "Salinidad", "Zinc", "Potasio")]

# Define plot layout
par(mfrow = c(2,2))

# Loop through predictors
for(i in names(X)) {
  
  plot(X[[i]], res_2,
       xlab = i,
       ylab = "Residuos estandarizados",
       main = paste("Residuos vs", i))
  
  abline(h = 0, col = "red")
}


