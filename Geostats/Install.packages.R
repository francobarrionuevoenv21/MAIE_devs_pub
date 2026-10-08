# Paquetes de R para los prácticos de Análisis Espacial - Instituto Gulich 2026
# Correr una vez, completo, antes de la primera clase práctica.

paquetes <- c(
  # datos espaciales y mapas
  "sf", "stars", "terra", "spData", "mapview", "tmap",
  # autocorrelación, geoestadística y modelos mixtos
  "spdep", "gstat", "nlme",
  # manejo de datos y gráficos
  "dplyr", "tidyr", "ggplot2", "patchwork", "scales",
  # árboles, Random Forest y validación
  "rpart", "rpart.plot", "randomForest", "ranger", "caret", "CAST",
  "FNN", "e1071", "car", "MASS",
  # tidymodels (scripts 08b y 09b)
  "tidymodels", "spatialsample", "waywiser"
)

faltan <- setdiff(paquetes, rownames(installed.packages()))
if (length(faltan) > 0) install.packages(faltan)

# Verificación: todos deberían cargar sin error
ok <- sapply(paquetes, requireNamespace, quietly = TRUE)
if (all(ok)) {
  message("Todos los paquetes están instalados.")
} else {
  message("No se pudieron instalar: ", paste(names(ok)[!ok], collapse = ", "))
}



paquetes <- c(
  "sf", "stars", "terra", "spData", "mapview", "tmap",
  "spdep", "gstat", "nlme",
  "dplyr", "tidyr", "ggplot2", "patchwork", "scales",
  "rpart", "rpart.plot", "randomForest", "ranger", "caret", "CAST",
  "FNN", "e1071", "car", "MASS",
  "tidymodels", "spatialsample", "waywiser"
)

instalados <- paquetes %in% rownames(installed.packages())

data.frame(
  paquete = paquetes,
  instalado = instalados
)

install.packages(c(
  "stars",
  "terra",
  "spdep",
  "gstat"
))

install.packages(c(
  "mapview",
  "tmap"
))

install.packages(c(
  "CAST",
  "car"
))

install.packages(c(
  "tidymodels",
  "spatialsample",
  "waywiser"
))


log <- capture.output(
  install.packages("fs", verbose = TRUE),
  type = "output"
)

writeLines(log, "~/fs_install.log")

cat("~/fs_install.log", sep = "\n")



install.packages(c("mapview", "tmap"))
