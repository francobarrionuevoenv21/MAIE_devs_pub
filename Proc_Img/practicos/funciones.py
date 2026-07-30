#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------------
# Created By  :
# Created Date:

# Importo liberías de base
import numpy as np

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
