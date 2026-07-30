#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------------
# Created By  :
# Created Date:

# Importo liberías de base
import numpy as np
import rasterio
from rasterio.windows import Window

# Funciones creadas
def scale(imagen, p, nodata = None):
  # Calcular los percentiles p y 100-p
  valor_min = np.percentile(imagen[imagen != nodata], p)
  valor_max = np.percentile(imagen[imagen != nodata], 100-p)

  # Truncar la imagen al rango [p1, p99]
  ecualizada = np.clip(imagen, valor_min, valor_max)

  # Normalizar la imagen al rango 0-255.
  ecualizada = (ecualizada - valor_min) / (valor_max - valor_min) * 255

  # Convertir la imagen ecualizada a entero de 8 bits
  ecualizada = np.uint8(ecualizada)

  # Retornar la imagen ecualizada
  return ecualizada

def subset_img(ds, bands_list, ul_x, ul_y, lr_x, lr_y):
    '''
    Parámetros:
    ds: Rasterio dataset;
    bands_list: Lista de bandas a seleccionar. Si es singleband: [1];
    ul_x: Coordenada x del extremo superior izquierdo;
    ul_y: Coordenada y del extremo superior izquierdo;
    lr_x: Coordenada x del extremo inferior derecho;
    lr_y: Coordenada y del extremo inferior derecho;
    ---
    Return
    subset: dataarray recortado según las coordenadas indicadas; 
    window: Elemento Window de rasterio según las coordenadas indicadas
    '''
    row_off, col_off = ds.index(ul_x, ul_y) # https://rasterio-readthedocs-io.translate.goog/en/stable/quickstart.html?_x_tr_sl=en&_x_tr_tl=es&_x_tr_hl=es&_x_tr_pto=tc#spatial-indexing
    ps_x = ds.transform.a
    ps_y = ds.transform.e*(-1)
    width = abs(round((lr_x-ul_x)/ps_x))
    height = abs(round((ul_y-lr_y)/ps_y))

    window = Window(col_off, row_off, width, height) # (col_off, row_off, width, height)
    subset = ds.read(bands_list, window = window)[0] # [0] --> convierto de 3D a 2D

    return subset, window