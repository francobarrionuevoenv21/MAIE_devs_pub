// 1️⃣ Definir la zona de estudio
// IMPORTANTE: Asegúrate de dibujar tu polígono en el mapa y llamarlo 'studyArea'
// var studyArea = ee.Geometry.Point([-64.5, -31.5]).buffer(10000); // (Descomentar si no tienes uno dibujado)

// Mostrar la zona de estudio en el mapa
Map.centerObject(studyArea, 10);
Map.addLayer(studyArea, {color: 'red'}, 'Zona de Estudio', false);

// 2️⃣ Cargar imagen Landsat 8 y recortar al área de estudio
var image = ee.ImageCollection('LANDSAT/LC08/C02/T1_TOA')
  .filterBounds(studyArea)
  .filterDate('2024-11-01', '2025-02-01')  
  .filter(ee.Filter.lt('CLOUD_COVER', 30))
  .median()
  .select(['B2', 'B3', 'B4', 'B5', 'B6', 'B7'])
  .clip(studyArea); // Recortar la imagen al polígono

// 3️⃣ Clasificación No Supervisada - K-Means
var trainingDataKMeans = image.sample({
  region: studyArea,
  scale: 30,
  numPixels: 5000, // Número de muestras
  seed: 42
});

var clusterer = ee.Clusterer.wekaKMeans(6).train(trainingDataKMeans);
var classifiedUnsupervised = image.cluster(clusterer);

// ==========================================
// 4️⃣ CLASIFICACIÓN SUPERVISADA
// ==========================================
// Definir muestras de entrenamiento (Asegúrate de tener geometry, geometry2, etc. dibujadas)
var arroz_f = ee.FeatureCollection([cultArroz]).map(function(f) {
  return f.set('class', 0);
});

var urbano_f = ee.FeatureCollection([urbano]).map(function(f) {
  return f.set('class', 1);
});

var agua_f = ee.FeatureCollection([cAgua]).map(function(f) {
  return f.set('class', 2);
});

var agro_f = ee.FeatureCollection([otrosCultv]).map(function(f) {
  return f.set('class', 3);
});

var vegt_f = ee.FeatureCollection([vegtNat]).map(function(f) {
  return f.set('class', 4);
});

// Unir todas las muestras en un solo conjunto de polígonos
var Samples = arroz_f.merge(urbano_f).merge(agua_f).merge(agro_f).merge(vegt_f);

// ✅ CORRECCIÓN 1: Extraer los valores espectrales UNA SOLA VEZ
var extractedData = image.sampleRegions({
  collection: Samples,
  properties: ['class'],
  scale: 30, // Cambiado a 30m (Landsat)
  tileScale: 4
});

// ⚠️ PASO CRÍTICO: División 70% Entrenamiento / 30% Validación
var withRandom = extractedData.randomColumn('random');
var split = 0.7; 
// ✅ CORRECCIÓN 2: Estos ya son los datos finales listos para usar
var trainingSamples = withRandom.filter(ee.Filter.lt('random', split));
var validationSamples = withRandom.filter(ee.Filter.gte('random', split));

// 5️⃣ Entrenar el clasificador Random Forest MODELO
var classifier = ee.Classifier.smileRandomForest(100).train({ // Sugerencia: 50 árboles es mejor que 10
  features: trainingSamples, // Pasamos las muestras directamente
  classProperty: 'class',
  inputProperties: image.bandNames()
});

// Aplicar la clasificación supervisada PREDICCION
var classifiedSupervised = image.classify(classifier);

// 6️⃣ Aplicar filtro de moda (mode) con un kernel de 3x3 píxeles
var kernel = ee.Kernel.square(3);

// Aplicar filtro de moda para suavizar la clasificación sin perder bordes
var smoothedClassification = classifiedSupervised.reduceNeighborhood({
  reducer: ee.Reducer.mode(),
  kernel: kernel
});

// 7️⃣ Visualización en el mapa
Map.centerObject(studyArea, 12);
Map.addLayer(image, {bands: ['B4', 'B3', 'B2'], min: 0, max: 0.3}, 'Landsat Original');
Map.addLayer(classifiedSupervised, {min: 0, max: 3, palette: ['blue', 'green', 'red', 'yellow']}, 'Clasificación RF Original');
Map.addLayer(smoothedClassification, {min: 0, max: 3, palette: ['blue', 'green', 'red', 'yellow']}, 'Clasificación RF Suavizada');
Map.addLayer(classifiedUnsupervised.randomVisualizer(), {}, 'Clasificación K-Means');

// 8️⃣ Evaluación: Matriz de Confusión y Métricas
// ✅ CORRECCIÓN 3: Clasificamos directamente los datos de validación
var validated = validationSamples.classify(classifier);

// Generar la matriz de confusión
var confusionMatrix = validated.errorMatrix('class', 'classification');
print('Matriz de Confusión:', confusionMatrix);

// Calcular coeficiente Kappa y Overall Accuracy
var overallAccuracy = confusionMatrix.accuracy();
var kappa = confusionMatrix.kappa();
print('Overall Accuracy:', overallAccuracy);
print('Coeficiente Kappa:', kappa);

// 9️⃣ Conteo de píxeles por clase
var pixelCountOriginal = classifiedSupervised.reduceRegion({
  reducer: ee.Reducer.frequencyHistogram(),
  geometry: studyArea,
  scale: 30,
  bestEffort: true
});
print('Conteo de píxeles por clase (Supervisada Original):', pixelCountOriginal);

var pixelCountSmoothed = smoothedClassification.reduceRegion({
  reducer: ee.Reducer.frequencyHistogram(),
  geometry: studyArea,
  scale: 30,
  bestEffort: true
});
print('Conteo de píxeles por clase (Supervisada Suavizada):', pixelCountSmoothed);

// 1️⃣0️⃣ Exportar Resultados como GeoTIFF

/*
Export.image.toDrive({
  image: classifiedSupervised,
  description: 'Clasificacion_RF_Original',
  scale: 30,
  region: studyArea,
  fileFormat: 'GeoTIFF',
  maxPixels: 1e13
});

Export.image.toDrive({
  image: smoothedClassification,
  description: 'Clasificacion_RF_Suavizada',
  scale: 30,
  region: studyArea,
  fileFormat: 'GeoTIFF',
  maxPixels: 1e13
});

Export.image.toDrive({
  image: classifiedUnsupervised,
  description: 'Clasificacion_KMeans',
  scale: 30,
  region: studyArea,
  fileFormat: 'GeoTIFF',
  maxPixels: 1e13
});



Export.image.toDrive({
  image: image,
  description: 'rgb_studyarea',
  scale: 30,
  region: studyArea,
  fileFormat: 'GeoTIFF',
  maxPixels: 1e13
});

*/
