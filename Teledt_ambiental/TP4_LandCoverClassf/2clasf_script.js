//En este caso es una imagen Sentinel 2 del 06/01/2026 correspondiente al Tile T20JLL, que es el que comprende 
//nuestra área de estudio. Creamos la variable "S2_20260106" a partir de la imagen indicada. 
var S2_20260106 = ee.Image ('COPERNICUS/S2_SR_HARMONIZED/20260106T141721_20260106T142327_T20JLL');

//Ahora creamos la variable "bandas" que contiene los nombres de las bandas de Sentinel 2 con las que queremos 
//seguir trabajando. 
var bandas = ['B2','B3','B4','B5', 'B6', 'B7', 'B8', 'B8A', 'B11','B12']; 
//Luego actualizamos nuestra variable "S2_20260106" para que solo contenga las bandas que nos interesan utilizando la función 'select' 
var S2_20260106 = S2_20260106.select(bandas); 
//Imprimimos las características de la imagen para consultar sus metadatos desde la pestaña "console" 
print(S2_20260106, 'S2_20260106');

// Para visualizar la imagen en pantalla utilizamos la función 'Map.addLayer'
// Con 'S2_20260106.clip(AOI)' estamos recortando la imagen a la variable a nuestra área de estudio. 
// Añadimos la imagen a la vista haciendo una composición de color real: Rojo-Verde-Azul y le asigno el nombre con 
//el que quiero etiquetarla en la vista 
Map.addLayer (S2_20260106.clip(AOI), {max: 2500.0, min: 100.0, gamma: 1.0, bands: ['B4','B3','B2']}, 
'S2_20260106'); 

// Añadimos también una imagen invernal del 25/5/2026, del mismo Tile y creamos la variable "S2_20260526" 
var S2_20260526 = ee.Image ('COPERNICUS/S2_SR_HARMONIZED/20260526T141711_20260526T142402_T20JLL'); 
var S2_20260526 = S2_20260526.select(bandas); 
//print (S2_20260526, ' S2_20260526 '); // para ver los metadatos en la pestaña "console" 
Map.addLayer (S2_20260526.clip(AOI), {max: 2000.0, min: 0.0, gamma: 1.0, bands: ['B4','B3','B2']}, 'S2_20260526'); 

// Agregamos los límites del área de estudio en color amarillo: parametrizamos y representamos el relleno, grosor, 
//color y transparencia 
var RellenoAOI = ee.Image().byte(); 
var AreaEstudio = RellenoAOI.paint({featureCollection: AOI, width: 4,}); 
Map.addLayer(AreaEstudio, {palette: 'yellow', opacity: 1}, 'AreaEstudio');

//Queremos incluir en nuestra clasificación dos índices espectrales, el NDVI y el Urban Index (UI)

//Se calcula el Índice NDVI para las dos imágenes utilizando la función 'normalizedDifference', creando las variables NDVI_ver y NDVI_inv
var NDVI_ver = S2_20260106.normalizedDifference(['B8', 'B4']);  
//Map.addLayer (NDVI_ver.clip(AOI), {max: 1, min: -1,}, 'NDVI_ver'); 
var NDVI_inv = S2_20260526.normalizedDifference(['B8', 'B4']); 
//Map.addLayer (NDVI_inv.clip(AOI), {max: 1, min: -1,}, 'NDVI_inv')

// --
var NDWI_ver = S2_20260106.normalizedDifference(['B8', 'B3']);  
var NDWI_inv = S2_20260526.normalizedDifference(['B8', 'B3']); 

//Se calcula el Urban Index (UI) para las dos imágenes, del mismo modo que se calculó el NDVI y las agrego a la vista 
var UI_ver = S2_20260106.normalizedDifference(['B12', 'B8A']);
//Map.addLayer (UI_ver.clip(AOI), {max: 1, min: -1,}, 'UI_ver '); 
var UI_inv = S2_20260526.normalizedDifference(['B12', 'B8A']); 
//Map.addLayer (UI_inv.clip(AOI), {max: 1, min: -1,}, 'UI_inv '); */

// Agregamos los índices calculados a las imágenes correspondientes utilizando la función 'addBands', creando las 
//variables 'stack_ver' y 'stack_inv'

// --
var stack_ver = S2_20260106.addBands(NDVI_ver.rename('NDVI_ver')); 
var stack_ver = stack_ver.addBands(NDWI_ver.rename('NDWI_ver'));
var stack_ver = stack_ver.addBands(UI_ver.rename('UI_ver')); //Nótese que agregamos el UI al stack que ya 

// --
var stack_inv = S2_20260526.addBands(NDVI_inv.rename('NDVI_inv'));
var stack_inv = stack_inv.addBands(NDWI_inv.rename('NDWI_inv'));
var stack_inv = stack_inv.addBands(UI_inv.rename('UI_inv')); //Nótese que agregamos el UI al stack que ya //contenía 
//el NDVI 
//Imprimimos los stacks para ver sus metadatos en la pestaña "Console" 
//print(stack_ver, 'stack_ver'); 
//print(stack_inv, 'stack_inv');

//Ahora combinamos los stacks de invierno y verano utilizando la función 'addBands': 
var stack_S2 = stack_ver.addBands(stack_inv) 
//Agrego el Modelo Digital de Elevaciones SRTM de 30 m, disponible en el catálogo de productos de GEE. Para ello 
//creo la variable 'srtm' y la visualizo utilizando la función 'Map.addLayer' 
var srtm = ee.Image("USGS/SRTMGL1_003"); 
//Map.addLayer( srtm.clip(AOI), {bands: ['elevation'], min: [400], max:[2000] } , "SRTM_30m" ); 
//Agrego la capa de elevación al stack de las dos imágenes S2 con sus respectivos índices NDVI y UI 
stack_S2 = stack_S2.addBands(srtm.rename('elev')) 
//print(stack_S2, 'stack_S2')
//Agregamos a la vista los puntos de verdad de campo para los que identificamos el tipo de cubierta de suelo 
//utilizando la función 'draw' y la denominamos 'PuntosCampo' en la vista 
Map.addLayer(PuntosCampo.draw({color:'yellow'}), {}, 'PuntosCampo'); 

//Centramos la imagen en la vista del visor y asignamos un zoom de nivel 11 
//Map.centerObject (AOI, 11);

//**********************************************************************************************************//

//Clasificación 
// Se combinan las variables que representan los datos de referencia que utilizaremos para entrenar y validar 
var DataRef = 
Bosque.merge(Arbustal).merge(Pastizal).merge(Roca).merge(Agua).merge(Cultivo).merge(Urbanizacion); 
//Creamos en la capa DataRef una columna llamada 'random' con números al azar entre 0 y 1  
var seed = 2026; 
DataRef = DataRef.randomColumn('random', seed);

// Ahora para todos los píxeles comprendidos en los polígonos del set de datos, se extrae información del 
//stack_S2 (compuesto por las bandas de las 2 imágenes, índices y DEM), y las propiedades 'random' y 'landcover' 
var VerdadCampo = stack_S2.sampleRegions({ 
collection: DataRef, 
properties: ['random','landcover',], 
scale: 10 
}); 
//print(VerdadCampo, 'VerdadCampo');


// Separación entre Entrenamiento y validación. Identificar umbral de separación 
var training = VerdadCampo.filterMetadata('random', 'less_than', 0.7); 
var testing = VerdadCampo.filterMetadata('random', 'not_less_than', 0.7); 
print('Number of samples:', training.size());
print('Number of samples:', testing.size());

// Selecciono las bandas para el entrenamiento 
//var bandas_clas = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B11', 'B12', 'NDVI_ver', 'UI_ver', 
//'B2_1', 'B3_1', 'B4_1', 'B5_1', 'B6_1', 'B7_1', 'B8_1', 'B8A_1', 'B11_1', 'B12_1', 'NDVI_inv', 'UI_inv', 'elev']; 

var bandas_clas = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B11', 'B12', 'NDVI_ver', 'UI_ver', 
'B2_1', 'B3_1', 'B4_1', 'B5_1', 'B6_1', 'B7_1', 'B8_1', 'B8A_1', 'B11_1', 'B12_1', 'NDVI_inv', 'UI_inv', 
'elev', 'NDWI_ver', 'NDWI_inv']; 


// Entrenamiento del clasificador Random Forest. training es el conjunto de entrenamiento, la clase está indicada en 
//la propiedad 'landcover' y el conjunto de bandas es 'bandas_clas' 
var clasificador = ee.Classifier.smileRandomForest(
    120,      // numberOfTrees
    7,    // variablesPerSplit
    3,       // minLeafPopulation
    0.8,      // bagFraction
    42       // seed
      ).train(training, 'landcover', bandas_clas);
      
      
//Clasificamos el stack_S2 creando la variable 'clasificación'. 
var clasificacion = stack_S2.select(bandas_clas).classify(clasificador).clip(AOI);
//print(clasificacion, 'clasificacion') 

// Apply a spatial median filter with a 3x3 pixel window
var modeFilter = clasificacion.focal_max({ // Focal mode used most frequently in classification
  radius: 1, 
  kernelType: 'square', 
  units: 'pixels', 
  iterations: 1
});

// Definimos la paleta de colores con la que queremos representar a cada una de las clases en el mapa generado. 
var palette = [ 
'#006a06',//Bosque// verde oscuro 
'#98ff00',//  Arbustal // verde claro 
'#f5ff00', // Pastizal // amarillo 
'#ffffff', //Roca  // blanco 
'#032cd6', // Agua  //azul 
'#bf04c2', // Cultivo  // magenta 
'#958f87', // Urbanizacion // gris 
];

// Agregamos la clasificación a la vista, indicando la paleta de colores creada anteriormente. 
Map.addLayer(clasificacion, {min: 1, max: 7, palette: palette}, 'Clasificacion');
// -
Map.addLayer(modeFilter, {min: 1, max: 7, palette: palette}, 'Clasificacion Foc. Mode.');

// Generación de matriz de confusión e impresión en la pestaña 'Console' 
var validacion = testing.classify(clasificador); 
var errorMatrix = validacion.errorMatrix('landcover', 'classification'); 
print('Matriz de Confusión:', errorMatrix); 
print('Precisión Global:', errorMatrix.accuracy()); 
print('Precisión del Usuario:', errorMatrix.consumersAccuracy()); 
print('Precisión del Productor:', errorMatrix.producersAccuracy()); 

//Exporto el mapa clasificado al Drive 
Export.image.toDrive({ 
image: clasificacion, 
description: 'Mapa_cobertura_RF',//nombre con que aparece en la pestaña 'Tasks' 
scale: 10, 
region: AOI 
});

//creo y exporto la matriz de confusión 
var matrizconfusion = ee.Feature(null, {matrix: errorMatrix.array()}) 
Export.table.toDrive({ 
collection: ee.FeatureCollection(matrizconfusion), 
description: 'MatrizConfusion',//nombre con que aparece en la pestaña 'Tasks' 
fileFormat: 'CSV' 
});