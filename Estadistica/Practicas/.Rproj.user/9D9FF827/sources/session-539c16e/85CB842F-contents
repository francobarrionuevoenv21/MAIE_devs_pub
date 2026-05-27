# read a txt file
ndvi_p <-
  read.table("datos/ndvi_p.txt")

# display table characteristics
paste("n filas: ", nrow(ndvi_p))
paste("n columnas: ", ncol(ndvi_p))
paste("dimensiones: ", dim(ndvi_p))
paste("data type primera column: ", class(ndvi_p[, 1]))

## print first row
ndvi_p[1, ]

## print first column
ndvi_p[, 1]

## replace value
print(ndvi_p[1, 1])
ndvi_p[1, 1] <- 5 # replace and put 5
print(ndvi_p[1, 1])

## compute mean ndvi value
mean(ndvi_p$ndvi)


## summary
summary(ndvi_p)


## plot histogram
hist(ndvi_p$ndvi)
