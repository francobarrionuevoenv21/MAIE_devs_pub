##****************************************************************************##
## 1. Lagartos reposando
"
El archivo lizard.txt contiene 332 observaciones relacionadas lagartos de la especie Sceloporus
occidentalis (western fence lizards). Cada vez que se observó un lagarto de esta especie reposando,
se registró el lugar en el que se lo observó: desierto, montaña o valle y la cantidad de sol que estaba
recibiendo el cuerpo del lagarto cuando fue visto: sun: el lagarto fue visto reposando completamente
al sol, partial: el lagarto fue visto con parte de su cuerpo al sol y parte de su cuerpo a la sombra,
shade: el cuerpo del lagarto estaba completamente a la sobra.

1.1. Objetivo
Evaluar si existe asociación entre el lugar donde se observó el lagarto y la cantidad de sol que recibía.

1.2. Actividades
1. Construya una tabla de contingencia.
2. Calcule proporciones.
3. Calcule los valores esperado bajo independencia.
4. Realice una prueba de independencia.
5. Concluya sobre los resultados.
"
##****************************************************************************##

## Read data
data_liz <- read.table("datos/lizard.txt", head=TRUE)

## Display table head
head(data_liz)

## --
unique(data_liz$site)
unique(data_liz$sunlight)

## --
tabla<-table(data_liz$site, data_liz$sunlight)
tabla

##------------------------------------------------------------------------------
"
          partial shade sun
desert        32    71  16
mountain      36    15  56
valley        40    24  42
"
##------------------------------------------------------------------------------

## Create table w/ sum by row and column 
table_addm <- addmargins(tabla)
table_addm

## Compute proportions
table_prop <- proportions(table_addm)
table_prop

## Chi square test
chi<-chisq.test(tabla,correct=F)
chi

##------------------------------------------------------------------------------
"
OUTPUT:
Pearson's Chi-squared test

data:  tabla
X-squared = 68.773, df = 4, p-value = 4.121e-14

CONCLUSSION: Reject H0 ==> it exists an asociation between ecosystem and the
amount of sun

"
##------------------------------------------------------------------------------

chi$stdres
