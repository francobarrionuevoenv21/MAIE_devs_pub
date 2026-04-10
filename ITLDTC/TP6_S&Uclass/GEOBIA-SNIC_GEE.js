// ==============================================================================
// PRÁCTICO 2: GEOBIA y Segmentación con SNIC en Google Earth Engine
// Objetivo: Encontrar la escala óptima de segmentación para un paisaje agrícola.
// ==============================================================================

// 1. Definir el Área de Estudio (Zona Agrícola: Córdoba)
var roi = roi.buffer(2000);
Map.centerObject(roi, 13);

// 2. Cargar imagen Sentinel-2 (Baja nubosidad, época de cultivos en pie)
var s2 = ee.ImageCollection("COPERNICUS/S2_SR_HARMONIZED")
  .filterBounds(roi)
  .filterDate('2023-01-01', '2023-03-31')
  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 5))
  .median() // Tomamos la mediana para limpiar ruido
  .select(['B4', 'B3', 'B2', 'B8']) // Rojo, Verde, Azul, NIR
  .clip(roi);

// Visualización de la imagen original (Falso Color)
var visParams = {min: 0, max: 3000, bands: ['B8', 'B4', 'B3']};
Map.addLayer(s2, visParams, '1. Sentinel-2 (Original Píxel)', false);

// ==============================================================================
// 3. ZONA DE TRABAJO DEL ALUMNO: Parámetros del Algoritmo SNIC
// ==============================================================================
// Modifique estos valores para generar las 3 capturas del trabajo práctico:
// - size: Distancia entre semillas (Ej: pruebe 10, 50 y 150)
// - compactness: Qué tan cuadrados (alto) o irregulares (bajo) son los objetos (Ej: 0.1 a 1)

var tamaño_semilla = 40;  // <-- ¡CAMBIAR AQUÍ! (Scale)
var compacidad = 0.45;     // <-- ¡CAMBIAR AQUÍ! (Shape/Compactness)

// ==============================================================================

// 4. Ejecutar la Segmentación SNIC
var snic = ee.Algorithms.Image.Segmentation.SNIC({
  image: s2,
  size: tamaño_semilla,
  compactness: compacidad,
  connectivity: 8, // Conexión de píxeles (8 vecinos)
  neighborhoodSize: 256,
  seeds: ee.Algorithms.Image.Segmentation.seedGrid(tamaño_semilla)
});

// El resultado de SNIC nos da una banda llamada 'clusters' con el ID del objeto
var clusters = snic.select('clusters');

// 5. Visualización Aleatoria de los Objetos (Para ver la geometría)
Map.addLayer(clusters.randomVisualizer(), {}, '2. Objetos Segmentados (Color Aleatorio)');

// 6. Calcular la "Imagen Basada en Objetos" (Promedio de píxeles por objeto)
// Esto demuestra cómo GEOBIA suaviza la varianza "sal y pimienta"
var objectBasedImage = s2.addBands(clusters).reduceConnectedComponents({
  reducer: ee.Reducer.mean(),
  labelBand: 'clusters'
});

Map.addLayer(objectBasedImage, visParams, '3. Imagen Suavizada por Objeto');

// 7. Extraer los bordes de los polígonos para verlos sobre la imagen original
var edges = ee.Algorithms.CannyEdgeDetector(clusters, 1, 0);
var borders = edges.updateMask(edges.gt(0));
Map.addLayer(borders, {palette: ['#FFFFFF']}, '4. Fronteras de los Objetos', true);

print("✅ Segmentación completada. Observe el mapa y las fronteras rojas.");
print("Parámetros actuales -> Size:", tamaño_semilla, "| Compactness:", compacidad);