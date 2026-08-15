#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------------
# Created By  :
# Created Date:

# Importo liberías de base
import numpy as np
import rasterio
from rasterio.windows import Window
import scipy.ndimage
from zipfile import ZipFile
import os

# Funciones creadas
def scale(imagen, p, nodata = None):
  # Calcular los percentiles p y 100-p
  valor_min = np.percentile(imagen[imagen != nodata], p)
  valor_max = np.percentile(imagen[imagen != nodata], 100-p)
  print(valor_min, valor_max)

  # Truncar la imagen al rango [pInf, pSup]
  ecualizada = np.clip(imagen, valor_min, valor_max)

  # Normalizar la imagen al rango 0-255.
  ecualizada = (ecualizada - valor_min) / (valor_max - valor_min) * 255

  # Convertir la imagen ecualizada a entero de 8 bits
  ecualizada = np.uint8(ecualizada)

  # Retornar la imagen ecualizada
  return ecualizada

def subset_img(ds, ul_x, ul_y, lr_x, lr_y, bands_list = [1]):
    '''
    Parámetros:
    ds: Rasterio dataset;
    ul_x: Coordenada x del extremo superior izquierdo;
    ul_y: Coordenada y del extremo superior izquierdo;
    lr_x: Coordenada x del extremo inferior derecho;
    lr_y: Coordenada y del extremo inferior derecho;
    bands_list: Lista de bandas a seleccionar. Si es singleband: [1] (Default);
    ---
    Return
    subset: dataarray recortado según las coordenadas indicadas; 
    window: Elemento Window de rasterio según las coordenadas indicadas
    '''
    row_off, col_off = ds.index(ul_x, ul_y) # https://rasterio-readthedocs-io.translate.goog/en/stable/quickstart.html?_x_tr_sl=en&_x_tr_tl=es&_x_tr_hl=es&_x_tr_pto=tc#spatial-indexing
    ps_x = ds.transform.a
    ps_y = ds.transform.e*(-1)
    width = (round((lr_x-ul_x)/ps_x))
    height = (round((ul_y-lr_y)/ps_y))

    window = Window(col_off, row_off, width, height) # (col_off, row_off, width, height)
    subset = ds.read(bands_list, window = window) # [0] --> convierto de 3D a 2D

    return subset, window

def scale_multiband(imagen, p = 0, nodata = None):
    '''
    Parámetros:
    imagen: 3D datarray con n bandas/canales
    p: percentil para escalado de la imagen
    nodata: valor No Data para ecualizado de la imagen
    ---
    Return
    imagen_escalada: 3D datarray escalado 
    ---
    NOTA: Para plotear con matplotlib en RGB usar el comando .transpose(1,2,0)
    '''
    # Crear un array vacio con la misma estructura que imagen_spot_apilada, pero con tipo de dato uint8 (en caso de usar la función scale que escala a 0-255).
    imagen_escalada = np.empty_like(imagen, dtype=np.uint8)

    # Definir una variable con el número de canales
    canales = imagen_escalada.shape[0]

    # Escalar una a una las bandas (usando p)
    for i in range(canales):
      canal = imagen[i, :, :]
      imagen_escalada[i, :, :] = scale(canal, p)
      
    return imagen_escalada


def leer_bandas_l2a(zipfilename, bands_to_extract, res, poligono = None):
  '''Funcion para leer imagen S2 Nivel 2A desde ZIP
  Inputs: zipfilename: string, nombre del zip (ruta entera)
  bands_to_extract: Lista de bandas a extraer (Lista de strings). Ej: bands_to_extract = ['B02', 'B03', 'B04', 'B08']
  res: resolucion (ej: 10)
  poligono: poligono para aplicar recorte (en geodataframe). Por defecto no usa poligono
  '''
  zfile = ZipFile(zipfilename,'r')
  stack_bandas = []

  for bnd in zfile.namelist():
    dirname = os.path.basename(os.path.dirname(bnd))

    if dirname == f'R{res}m' and bnd.endswith('.jp2'):
        if os.path.basename(bnd).split('_')[2] in bands_to_extract:
            fname = f'/vsizip/{zipfilename}/{bnd}' # Agregmos /vsizip/ a cada ruta
            ds = rasterio.open(fname)
            metadatos = ds.meta
            if poligono is not None:
              clip, clip_transform = rasterio.mask.mask(ds, poligono.geometry, crop=True) # Extraemos una sección de la imagen solamente
              stack_bandas.append(clip[0])
              metadatos['transform'] = clip_transform # Si recortamos, actualizamos el transform de los metadatos
              metadatos['height'] = clip.shape[1] # Si recortamos, actualizamos el height de los metadatos
              metadatos['width'] = clip.shape[2] # Si recortamos, actualizamos el width de los metadatos
            else:  
              stack_bandas.append(ds.read()[0]) # Leemos como array 2D y lo agregamos a stack_bandas
  stack_bandas = np.array(stack_bandas)
  metadatos['count'] = stack_bandas.shape[0] # Actualizamos el count o numero de bandas
  metadatos['driver'] = 'GTiff' # Cambiamos el driver a GeoTiff
  return stack_bandas, metadatos


def resample_bands(src_bands,ref_bands):
    """
    Función auxiliar.
    Realiza el re-muestreo según la resolución elegida.
    """
    b = src_bands.shape[0]
    r = ref_bands.shape[1]
    c = ref_bands.shape[2]
    zf = float(r/src_bands.shape[1])
    src_resample =  np.zeros((b,r,c))
    for i,band in enumerate(src_bands):
        src_resample[i] = scipy.ndimage.zoom(src_bands[i],zf)
    return src_resample