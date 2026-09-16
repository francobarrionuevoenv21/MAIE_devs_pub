var collection = ee.ImageCollection('COPERNICUS/DEM/GLO30_2024_1');
var nativeProj = collection.first().projection();

// Mosaic collection and set default projection from a sample image
// to ensure terrain analysis is done in the native scale and CRS.
var dataset = collection.mosaic().setDefaultProjection(nativeProj);

var dataset_clip = dataset.select('DEM').clip(study_area.geometry());
Map.addLayer(dataset_clip, {min: 0, max: 3000}, 'DEM clipped');

Export.image.toDrive({
  image: dataset_clip.float().rename('dem_studyarea'),
  description: 'dem_studyarea',
  folder: 'GEE_exports',
  region: study_area.geometry(),
  scale: 30,
  crs: 'EPSG:4326',
  maxPixels: 1e13
});