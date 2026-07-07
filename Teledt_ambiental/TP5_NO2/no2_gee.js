// Serie temporal de NO2 troposférico, Pcia. de Corrientes, 2021 y 2022
// Fernanda García; Modificado por Franco Barriouevo
// Creación 03/02/2023; Modificado: 02/07/2026
// Modificado 30/96/2026

// Rename vector Corrientes, IGN
var study_area = fires_patag_2026//.geometry().buffer(100)
var set_buffer = 10000;
//print(study_area)

// Visualización de vector Pcia. Corrientes, IGN
Map.addLayer(study_area.draw ({color: 'black'}), {}, 'Limites study_area');


// FUNCIONES
// Funcion: media a partir de los valores mayores o iguales a cero
var gte0 = function(image) {
  var positivo = image.gte(0).multiply(image);
  return positivo
};

// Funcion: máscara para obtener los píxeles con datos, se usa para el n
var mask = function(image) {
  var maski = image.gte(0); // individual
  return maski
}; // porqué en el producto después tengo algunos valores con datos n=-9999 y otros con n=0?


//Datos Sentinel 5P para NO2
var N02 = ee.ImageCollection('COPERNICUS/S5P/OFFL/L3_NO2')
  
//Datos para columna NO2 Troposferico
var SentinelNO2Tropo_noFire = N02
  .select('tropospheric_NO2_column_number_density')
  .filterDate('2025-08-01', '2026-09-01') //Selección de periodo temporal
  .filterBounds (study_area.geometry().buffer(1000));

//Datos para columna NO2 Troposferico
var SentinelNO2Tropo_fire = N02
  .select('tropospheric_NO2_column_number_density')
  .filterDate('2026-01-01', '2026-02-01') //Selección de periodo temporal
  .filterBounds (study_area);
  

// acumulado
var NO2TropMicroClip_sumNofire = ee.Image(SentinelNO2Tropo_noFire.map(gte0).sum()
  .multiply(1e10)).round().divide(1e4).clip(study_area.geometry().buffer(1000)); // paso a micromol
var NO2TropMicroClipUnmasked_sumNoFire = NO2TropMicroClip_sumNofire.unmask(ee.Image.constant(-9999)); // cambio nan por -9999

var NO2TropMicroClip_sumFire = ee.Image(SentinelNO2Tropo_fire.map(gte0).sum()
  .multiply(1e10)).round().divide(1e4).clip(study_area.geometry().buffer(set_buffer)); // paso a micromol
var NO2TropMicroClipUnmasked_sumFire = NO2TropMicroClip_sumFire.unmask(ee.Image.constant(-9999)); // cambio nan por -9999

print("sum fire")
print(NO2TropMicroClip_sumFire)

// mediana
var NO2TropoDataMedianNofire = ee.Image(SentinelNO2Tropo_noFire.median());
var NO2TropoDataMedianNofire = NO2TropoDataMedianNofire.multiply(1e10).round().divide(1e4).clip(study_area.geometry().buffer(set_buffer));

var NO2TropoDataMedianFire = ee.Image(SentinelNO2Tropo_fire.median());
var NO2TropoDataMedianFire = NO2TropoDataMedianFire.multiply(1e10).round().divide(1e4).clip(study_area.geometry().buffer(set_buffer));

//desvío estándar
var SentinelNO2TropostdDev_noFire = SentinelNO2Tropo_noFire.map(gte0).reduce(ee.Reducer.stdDev())
    .multiply(1e10).round().divide(1e4).clip(study_area.geometry().buffer(set_buffer));

var SentinelNO2TropostdDev_fire = SentinelNO2Tropo_fire.map(gte0).reduce(ee.Reducer.stdDev())
    .multiply(1e10).round().divide(1e4).clip(study_area.geometry().buffer(set_buffer));

// n
var NO2TropNofireClip_n = ee.Image(SentinelNO2Tropo_noFire.map(mask).sum()).clip(study_area.geometry().buffer(set_buffer));
var NO2TropFireClip_n = ee.Image(SentinelNO2Tropo_fire.map(mask).sum()).clip(study_area.geometry().buffer(set_buffer));

// ************************************* ADD LAYERS *******************************************

Map.addLayer (NO2TropoDataMedianNofire, {
  max: 0.00003, 
  min: 0.0, 
  palette: ["white", "beige", "yellow", "orange", "red", "purple"]}, 
  'NO2 Troposférico Mediana Agosto 2025 (No incendios) ');
 
Map.addLayer (NO2TropoDataMedianFire, {
  max: 0.00003, 
  min: 0.0, 
  palette: ["white", "beige", "yellow", "orange", "red", "purple"]}, 
  'NO2 Troposférico Mediana Enero 2026 (Incendios)');
  
Map.addLayer (SentinelNO2TropostdDev_noFire, {
  max: 30, 
  min: 0.0, 
  palette: ["white", "beige", "yellow", "orange", "red", "purple"]}, 
  'NO2 Troposférico Desvio Estandar Agosto 2025 (No incendios)');
  
Map.addLayer (SentinelNO2TropostdDev_fire, {
  max: 30, 
  min: 0.0, 
  palette: ["white", "beige", "yellow", "orange", "red", "purple"]}, 
  'NO2 Troposférico Desvío Estándar Enero 2026 (Incendios)');

Map.addLayer (NO2TropMicroClip_sumNofire, {
  max: 1500, 
  min: 0.0, 
  palette: ["black", "blue", "purple", "cyan", "green", "yellow", "red"]}, 
  'NO2 Troposférico Acumulado Agosto 2025 (No incendios)');
  
Map.addLayer (NO2TropMicroClip_sumFire, {
  max: 1500, 
  min: 0.0, 
  palette: ["black", "blue", "purple", "cyan", "green", "yellow", "red"]}, 
  'NO2 Troposférico Acumulado Enero 2026 (Incendios)');
  
Map.addLayer (NO2TropNofireClip_n, {
  max: 58, 
  min: 0.0, 
  palette: ["black", "blue", "purple", "cyan", "green", "yellow", "red"]}, 
  'n datos NO2 Troposférico Agosto 2025 (No incendios)');
  
Map.addLayer (NO2TropFireClip_n, {
  max: 58, 
  min: 0.0, 
  palette: ["black", "blue", "purple", "cyan", "green", "yellow", "red"]}, 
  'n datos NO2 Troposférico Agosto 2025 (No incendios)');

// ************************************* END ADD LAYERS ***********************************

// ************************************* EXPORT DATA **************************************

Export.image.toDrive({
  image: NO2TropoDataMedianNofire.float().rename('NO2_median_2025'),
  description: 'NO2tropMed_0825_float_study_area',
  scale: 1100, 
  region: study_area});
  
Export.image.toDrive({
  image: NO2TropoDataMedianFire.float().rename('NO2_median_2026'),
  description: 'NO2tropMed_0126_float_study_area',
  scale: 1100, 
  region: study_area});
  
Export.image.toDrive({
  image: SentinelNO2TropostdDev_noFire.float().rename('NO2_std_2025'),
  description: 'NO2tropStd_0825_float_study_area',
  scale: 1100, 
  region: study_area});
  
Export.image.toDrive({
  image: SentinelNO2TropostdDev_fire.float().rename('NO2_std_2026'),
  description: 'NO2tropStd_0126_float_study_area',
  scale: 1100, 
  region: study_area});

// ************************************* END EXPORT DATA **********************************


// Series temporales
var date_1 = '2022-01-01'
var date_2 = '2022-12-31'

var col = ee.ImageCollection('COPERNICUS/S5P/OFFL/L3_NO2')
.filterBounds(study_area)
.filterDate(date_1,date_2)
.select('tropospheric_NO2_column_number_density')
.map(function(a) {
   return a.set('month',ee.Image(a).date().get('month'))
})

//print(col)

var months = ee.List(col.aggregate_array('month')).distinct()

print(months)

var mc = months.map(function(x) {
  return col.filterMetadata('month', 'equals', x).median().set('month', x)
  //return col.filterMetadata('day', 'equals', x).median().set('day', x)
})

var final_image = ee.ImageCollection.fromImages(mc)
//print(final_image)

var chart = ui.Chart.image.series(final_image, study_area, ee.Reducer.median(), 10000, 'month')
.setOptions({
  title: 'NO2 Concentration',
  vAxis: {title: 'Concentration'},
  hAxis: {title: 'Month'}
})

print(chart)

/*
// Export to CSV
Export.table.toDrive({
    collection: chart,
    description: 'Single_Location_NDVI_time_series',
    folder: 'earthengine',
    fileNamePrefix: 'ndvi_time_series_single',
    fileFormat: 'CSV'
})
*/

// ************************************* EXTRA COMMANDS **********************************


/*
// Este es el modo que quiere CONAE, en float32:
var NO2trop_2021_float = NO2TropoMedianClip2021.float().rename('NO2_median')
  .addBands(SentinelNO2TropostdDev_2021.float().rename('NO2_stdDev'))
  .addBands(NO2TropMicroClip_sum2021.float().rename('NO2_sum'))
  .addBands(NO2Trop2021Clip_n.float().rename('NO2_n'))

// Este es el modo que quiere CONAE, en float32:
var NO2trop_2022_float = NO2TropoMedianClip2022.float().rename('NO2_median')
  .addBands(SentinelNO2TropostdDev_2022.float().rename('NO2_stdDev'))
  .addBands(NO2TropMicroClip_sum2022.float().rename('NO2_sum'))
  .addBands(NO2Trop2022Clip_n.float().rename('NO2_n'))

Export.image.toDrive({
  image: NO2trop_2021_float,
  description: 'NO2trop_20210115_20210227_float_study_area',
  scale: 1100, // lo activo porque aunque hay pequeñas diferencias, disminuye muuucho el tamaño. tengo que revisar bien qué hace eso.
  region: study_area});

Export.image.toDrive({
  image: NO2trop_2022_float,
  description: 'NO2trop_20220115_20220227_float_study_area',
  scale: 1100, // lo activo porque aunque hay pequeñas diferencias, disminuye muuucho el tamaño. tengo que revisar bien qué hace eso.
  region: study_area});
*/
