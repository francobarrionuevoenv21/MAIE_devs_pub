datos_ndvi <- read.table("datos/ndvi_p.txt")

head(datos_ndvi)


ndvi_agri <- datos_ndvi$ndvi[datos_ndvi$zona == "agricola"]
ndvi_sier <- datos_ndvi$ndvi[datos_ndvi$zona == "sierra"]

##ndvi_agri
##ndvi_sier

## Define alpha/2
alpha_2 <- (5/2)/100

## Define z using t student distribution
zIzq_agri <- qt(alpha_2, length(ndvi_agri)-1)
zDer_agri <- qt(1-alpha_2, length(ndvi_agri)-1)

zIzq_sier <- qt(alpha_2, length(ndvi_sier)-1)
zDer_sier <- qt(1-alpha_2, length(ndvi_sier)-1)

## Compute mean values
xMean_agri <- mean(ndvi_agri) 
xMean_sier <- mean(ndvi_sier)

## Compute samples sd values
sd_agri <- sd(ndvi_agri)
sd_sier <- sd(ndvi_sier)

## Compute min and max 
min_agri <- xMean_agri + zIzq_agri*sd_agri/sqrt(length(ndvi_agri))
max_agri <- xMean_agri + zDer_agri*sd_agri/sqrt(length(ndvi_agri))

min_sier <- xMean_sier + zIzq_sier*sd_sier/sqrt(length(ndvi_sier))
max_sier <- xMean_sier + zDer_sier*sd_sier/sqrt(length(ndvi_sier))

print("Intervalo ndvi agrícola")
print("Min: ")
print(min_agri)
print("Max: ")
print(max_agri)

print("Intervalo ndvi sierra")
print("Min: ")
print(min_sier)
print("Max: ")
print(max_sier)


length(ndvi_agri)



