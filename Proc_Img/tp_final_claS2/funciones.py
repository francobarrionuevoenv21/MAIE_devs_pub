#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------------
# Created By  : Franco David Barrionuevo
# Created Date: Agosto 2026

# Librerías
import sys
import requests
import os
from pystac_client import Client

import numpy as np
import pandas as pd
import geopandas as gpd
import rasterio as rio
from rasterio.mask import mask

from matplotlib import pyplot as plt
import matplotlib.cm as cm
from matplotlib.colors import ListedColormap, BoundaryNorm
from mpl_toolkits.axes_grid1 import make_axes_locatable

import leafmap

# Funciones

# Defino path vector límites Embalse San Roque
ESR_PATH = 'https://github.com/francobarrionuevoenv21/MAIE_devs_pub/raw/refs/heads/main/Proc_Img/tp_final_claS2/data/esr_clean.geojson'


# Definición de las funciones

def explore_s2_items(date_ini, date_end, cv):
    """
    Busca ítems Sentinel-2 L2A en el catálogo STAC de AWS Earth Search dentro de un bounding box y rango de fechas.

    Args:
        date_ini (str): Fecha de inicio del rango de búsqueda (ej. "2023-01-01").
        date_end (str): Fecha de fin del rango de búsqueda (ej. "2023-01-31").
        cv (float): Porcentaje máximo de cobertura de nubes permitido (se retornan ítems con un valor menor a este).

    Returns:
        pystac.item_collection.ItemCollection: Colección de ítems Sentinel-2 que coinciden con la búsqueda.
    """
    
    # Import bounding box desde GitHub
    minx, miny, maxx, maxy = gpd.read_file(ESR_PATH)\
        .to_crs(epsg=4326)\
        .total_bounds  # minx, miny, maxx, maxy

    # URL actualizada del catálogo STAC
    STAC_URL = 'https://earth-search.aws.element84.com/v1'  # Catálogo: https://stacindex.org/catalogs?access=protected&type=static#/

    # Crea un cliente STAC usando la URL del catálogo
    client = Client.open(STAC_URL)

    # Define los parámetros de la búsqueda
    search_parameters = {
        'collections': ['sentinel-2-l2a'],  # Colección específica a buscar; Descripción procesamiento L2A: https://docs.sentinel-hub.com/api/latest/data/sentinel-2-l2a/
        'bbox': [minx, miny, maxx, maxy],  # Bounding box [oeste, sur, este, norte]
        'datetime': f'{date_ini}/{date_end}',
        'query': {'eo:cloud_cover': {'lt': cv}},  # Filtra por imágenes con menos del 10% de cobertura de nubes
        "limit": 100,  # Número de ítems por página de resultados
    }

    return client.search(**search_parameters).item_collection()

def df_items(stac_items):
    """
    Convierte ítems STAC en un DataFrame resumen con fecha, plataforma y cobertura de nubes.

    Args:
        stac_items (pystac.item_collection.ItemCollection): Colección de ítems STAC a procesar.

    Returns:
        pd.DataFrame: Una fila por ítem, con las columnas "Fecha", "Plataforma" y "Cloud Cover (%)".
    """
        
    # Defino propiedades a extraer
    properties_to_extract = [
        'datetime',
        'platform',
        'eo:cloud_cover',
    ]

    # Rename de las columnas del dataframe
    column_renames = {
        'datetime': 'Fecha',
        'platform': 'Plataforma',
        'eo:cloud_cover': 'Cloud Cover (%)',
    }
    
    # Extraigo los datos para la creación del dataframe
    data = []
    for item in stac_items:
        row = {}
        row['ID'] = item.id
        for prop in properties_to_extract:
            value = item.properties.get(prop, None)
            if prop == "datetime" and value is not None:
                value = value[:10]  # Keep only the date part (YYYY-MM-DD)
            row[prop] = value
        data.append(row)

    return pd.DataFrame(data).rename(columns=column_renames)

def down_assets(items, item_id, assets_folder, assets_down = ['red', 'nir']):
    """
    Descarga los assets (bandas) seleccionados de un ítem STAC a una carpeta local.

    Args:
        items (pystac.item_collection.ItemCollection): Colección de ítems STAC.
        item_id (int): Índice del ítem a descargar dentro de la colección.
        assets_folder (str): Ruta de la carpeta local donde se guardarán los archivos descargados.
        assets_down (list): Claves de los assets a descargar (default: ['red', 'nir']).

    Returns:
        dict: Mapeo de cada asset descargado a su código de plataforma y fecha de adquisición.
    """
    
    # Defino el ítem a descargar según el índice
    sel_item = items[item_id]

    # Extraemos información clave del elemento: fecha (YYYY-MM-DD) y platform code
    item_datetime = sel_item.properties.get("datetime", "Error")  # Check "Error" param value
    date_yymmdd = item_datetime[:10]  # 'YYYY-MM-DD'
    platform = sel_item.properties.get("platform", "Error")
    pltf_code = platform[-2:]

    # Creo diccionario vacío 
    dict_path_bands = {}

    # Recorremos los assets del ítem y descargo mediante request
    for asset_key, asset_data in sel_item.assets.items():
        # Verificamos si es uno de los assets deseados
        if asset_key in assets_down:
            url = asset_data.href

            dict_path_bands[asset_key] = {'pltf_code': pltf_code, 'date_yymmdd': date_yymmdd}

            # Construimos el nombre del archivo
            filename = f'S{pltf_code}_{date_yymmdd}_{asset_key}.tif'
            out_file = os.path.join(assets_folder, filename)

            print(f'Descargando asset: {asset_key}')
            response = requests.get(url, stream=True)  # Descarga el archivo en modo streaming

            with open(out_file, "wb") as f:
                f.write(response.content)

            print(f"Descarga completada en: {out_file}")

    print("Descargas de los assets finalizadas")

    return dict_path_bands

def clip_bands_bounds(assets_folder, dict_path_bands, assets_clip = ['red', 'nir']):
    """
    Recorta los rásters de bandas descargados según una geometría delimitadora y los retorna con sus metadatos.

    Args:
        assets_folder (str): Ruta de la carpeta local donde están almacenados los archivos de bandas.
        dict_path_bands (dict): Mapeo de cada asset a su código de plataforma y fecha de adquisición (devuelto por down_assets).
        assets_clip (list): Claves de los assets a recortar (default: ['red', 'nir']).

    Returns:
        dict: Mapeo de cada asset a un diccionario con el array 2D recortado ("subset"), los metadatos actualizados del ráster ("metadatos"), y la fecha de adquisición ("date").
    """
    
    # Import and read ESR vector and reproject to 32720
    bounds_gdf = gpd.read_file(ESR_PATH).dissolve()  # Apply disolve because vector structure
    bounds_gdf_32720 = bounds_gdf.to_crs(epsg=32720)

    # Guardado de los dataarrays de las bandas subseteadas en un diccionario (subset de bandas + ventanas + nodata)
    dict_bands_bounds = {}  # Creo un diccionario

    # Itero sobre la lista de paths para cada una de las bandas y las almaceno en el diccionario
    for i, asset in enumerate(assets_clip):
        band_path = os.path.join(
            assets_folder,
            f"S{dict_path_bands[asset]['pltf_code']}_{dict_path_bands[asset]['date_yymmdd']}_{asset}.tif"
        )
        band_ds = rio.open(band_path)

        band_mask, mask_transform = mask(dataset=band_ds, shapes=bounds_gdf_32720.geometry, nodata=None, crop=True)

        # Extraigo y actualizo metadatos
        bands_meta = band_ds.meta
        bands_meta.update({
            'height': band_mask.shape[1],
            'width': band_mask.shape[2],
            'transform': mask_transform,
            'nodata': None
        })

        dict_bands_bounds[asset] = {
            'subset': band_mask[0],  # Me quedo con el dataarray en 2D
            'metadatos': bands_meta,
            'date': dict_path_bands[asset]['date_yymmdd']
        }

    return dict_bands_bounds

def calc_chla(dict_clip_bands):
    """
    Estima la concentración de clorofila-a a partir de las bandas red y NIR usando un modelo semi-empírico de razón NIR/red.

    Args:
        dict_clip_bands (dict): Datos de bandas recortadas (devuelto por clip_bands_bounds), debe contener las claves 'red' y 'nir'.

    Returns:
        tuple: (chla_da, date) donde chla_da es un np.ndarray de valores de clorofila-a (limitados al rango [2.8, 288.5] según German et al. 2021) y date es la fecha de adquisición de la banda red.
    """
    
    # Extraigo los datos de las bandas como datarrays
    red_data = dict_clip_bands['red']['subset']
    nir_data = dict_clip_bands['nir']['subset']

    # Computo la concentración de cl-a según modelo semiempírico de German et al. (2021)
    chla_da = -5.57 + 80.13 * (nir_data / red_data)
    chla_da = np.clip(chla_da, 2.8, 288.5)  # Defino límites acorde a valores del modelo

    return chla_da, dict_clip_bands['red']['date']


def carlson_idx(chla_da):
    """
    Calcula las clases del Índice de Estado Trófico (TSI) de Carlson a partir de un array de clorofila-a.

    Args:
        chla_da (np.ndarray): Array de valores de concentración de clorofila-a.

    Returns:
        np.ndarray: Array de clases TSI (misma forma que chla_da), con NaN donde chla_da <= 0.
    """
    
    # Bin edges define intervals: <20, [20, 40), [40, 50), [50, 70), >=70
    bins = [20, 40, 50, 70]

    # Creo dataarray y asigno valores discretos de TSI según intervalos
    tsi_map_raw = np.full_like(chla_da, np.nan, dtype=float)

    mask = chla_da > 0 # Mask chl-a < 0 (Redundante, ya corregido en el cálculo de cl-a)
    tsi_map_raw[mask] = 9.81 * np.log(chla_da[mask]) + 30.6

    tsi_map_class = np.full(chla_da.shape, -1, dtype=int)
    tsi_map_class[mask] = np.digitize(tsi_map_raw[mask], bins) # Asigna un valor discreto a cada valor del datarray según los intervalos en bins

    tsi_map_class = np.where(tsi_map_class == -1, np.nan, tsi_map_class) # numpy.digitize asigna -1 los valores nan, por lo tanto reconvierto a nan

    return tsi_map_class


def comp_maps(dict_clip_bands):
    """
    Genera los mapas de clorofila-a e índice de estado trófico a partir de datos de bandas recortadas.

    Args:
        dict_clip_bands (dict): Datos de bandas recortadas (devuelto por clip_bands_bounds).

    Returns:
        tuple: (chla_map, tsi_map, date) donde chla_map y tsi_map son np.ndarray
            y date es la fecha de adquisición asociada a las bandas de entrada.
    """

    chla_map, date = calc_chla(dict_clip_bands)
    tsi_map = carlson_idx(chla_map)

    return chla_map, tsi_map, date

def save_maps(maps_folder, chla_map, tsi_map, dic_clip_bands):
    """
    Guarda los mapas de clorofila-a e índice de estado trófico como archivos GeoTIFF.

    Args:
        maps_folder (str): Ruta de la carpeta local donde se guardarán los rásters de salida.
        chla_map (np.ndarray): Mapa de concentración de clorofila-a.
        tsi_map (np.ndarray): Mapa de índice de estado trófico.
        dic_clip_bands (dict): Datos de bandas recortadas (devuelto por clip_bands_bounds), usado para la fecha y los metadatos.

    Returns:
        dict: Paths de los archivos guardados, con las claves "chla_path" y "tsi_path".
    """
    
    # Date scene extracting and paths 
    date = dic_clip_bands['red']['date']
    chla_path = os.path.join(maps_folder, f'S2_CHLA_{date}.tif')
    tsi_path = os.path.join(maps_folder, f'S2_TSI_{date}.tif')

    # Extraigo y actualizo metadatos
    bands_meta = dic_clip_bands['red']['metadatos']  # Extraigo la metadata desde el da de la banda red
    bands_meta.update({'dtype': 'float32', 'nodata': np.nan})

    # Exporto como tif mapa de concentración de cl-a
    with rio.open(chla_path, 'w', **bands_meta) as dst01:
        dst01.write(chla_map, 1)   # escribir en la banda 1
        dst01.set_band_description(1, 'chla_ug-l')

    # Exporto como tif mapa de TSI
    with rio.open(tsi_path, 'w', **bands_meta) as dst02:
        dst02.write(tsi_map, 1)   # escribir en la banda 1
        dst02.set_band_description(1, 'carlson_idx')

    return {'chla_path': chla_path, 'tsi_path': tsi_path}

def run_chla_s2(items, item_id, assets_folder, maps_folder):
    """
    Ejecuta el flujo completo de Sentinel-2 para el cálculo de clorofila-a de un solo ítem STAC.

    Orquesta la descarga de assets, el recorte de bandas, el cómputo de clorofila-a
    e índice de estado trófico, y el guardado de los rásters de salida.

    Args:
        items (pystac.item_collection.ItemCollection): Colección de ítems STAC.
        item_id (int): Índice del ítem a procesar dentro de la colección.
        assets_folder (str): Ruta de la carpeta local donde se guardarán las bandas descargadas.
        maps_folder (str): Ruta de la carpeta local donde se guardarán los mapas de salida (.tif).

    Returns:
        tuple: (maps_dict, paths_dict) donde:
            - maps_dict (dict): "chla_map", "tsi_map" (np.ndarray) y "date" (str).
            - paths_dict (dict): "chla_path" y "tsi_path" con las rutas de los archivos guardados.
    """
    
    print('PASO 1/4: Descargando assets de Sentinel-2... \n')
    dict_path_bands = down_assets(items, item_id, assets_folder)
    print('\n') # Add space because printing within down_assets
    print(f'✔ Assets descargados: {list(dict_path_bands.keys())}\n')

    print('PASO 2/4: Recortando bandas al área de interés...')
    dict_clip_bands = clip_bands_bounds(assets_folder, dict_path_bands)
    print('✔ Bandas recortadas\n')

    print('PASO 3/4: Calculando mapas de clorofila-a e índice de Carlson...')
    chla_map, tsi_map, date = comp_maps(dict_clip_bands)
    print(f'✔ Mapas calculados para la fecha {date}\n')

    print('PASO 4/4: Guardando mapas en formato .tif...')
    dict_maps = save_maps(maps_folder, chla_map, tsi_map, dict_clip_bands)
    print(f"✔ Mapas guardados en:\n  - {dict_maps['chla_path']}\n  - {dict_maps['tsi_path']}\n")

    print('Workflow finalizado con éxito.')

    return ({'chla_map': chla_map, 'tsi_map': tsi_map, 'date': date}, dict_maps)

def plot_maps(chla_map, tsi_map, date, figsize=(8, 6)):
    """
    Grafica los mapas de concentración de clorofila-a y del índice de Carlson (TSI) lado a lado.

    Args:
        chla_map (np.ndarray): Mapa de concentración de clorofila-a.
        tsi_map (np.ndarray): Mapa de clasificación del índice de estado trófico (TSI).
        date (str): Fecha de adquisición, usada en los títulos de los subgráficos.
        figsize (tuple): Tamaño de la figura en pulgadas (default: (8, 6)).

    Returns:
        None: Muestra la figura mediante plt.show().
    """
    
    fig, ax = plt.subplots(1, 2, figsize=figsize, constrained_layout=True)

     # --- Mapa de clorofila-a ---

    cmap = cm.get_cmap('BuGn').copy()
    cmap.set_bad(color="#6B544C92")

    im1 = ax[0].imshow(
        np.ma.masked_invalid(chla_map),
        cmap=cmap,
        vmin=np.nanpercentile(chla_map, 1),
        vmax=np.nanpercentile(chla_map, 99)
    )

    ax[0].set_title(f'Estimación concentración\nCl-a {date}', fontsize=12)
    ax[0].set_axis_off()

    divider = make_axes_locatable(ax[0])
    cax1 = divider.append_axes("right", size="5%", pad=0.05)

    fig.colorbar(
        im1,
        cax=cax1,
        label="Concentración de Clorofila-a [$\mu$$g/L$]"
    )

    # --- Capa de TSI ---

    colors = [
        "#2c7bb6",
        "#abd9e9",
        "#ffffbf",
        "#fdae61",
        "#d7191c"
    ]

    cmap = ListedColormap(colors)
    cmap.set_bad(color="#6B544C92")

    bounds = np.arange(-0.5, 5.5, 1)
    norm = BoundaryNorm(bounds, cmap.N)

    im2 = ax[1].imshow(
        tsi_map,
        cmap=cmap,
        norm=norm
    )

    ax[1].set_title(f'Índice de Carlson (TSI)\n{date}', fontsize=12)
    ax[1].set_axis_off()

    divider = make_axes_locatable(ax[1])
    cax2 = divider.append_axes("right", size="5%", pad=0.05)

    cbar = fig.colorbar(
        im2,
        cax=cax2,
        ticks=np.arange(5)
    )

    cbar.ax.set_yticklabels([
        "Ultraoligotrófico",
        "Oligotrófico",
        "Mesotrófico",
        "Eutrófico",
        "Hipertrófico"
    ])

    cbar.set_label("Estado trófico")

    plt.show()

def plot_maps_leaf(chla_path, tsi_path, chla_map, date):
    """
    Muestra los mapas ráster de clorofila-a y TSI en un mapa interactivo leafmap.

    Args:
        chla_path (str): Ruta del archivo GeoTIFF de clorofila-a guardado.
        tsi_path (str): Ruta del archivo GeoTIFF de TSI guardado.
        chla_map (np.ndarray): Array de clorofila-a, usado para calcular los límites de percentiles del colormap.
        date (str): Fecha de adquisición, usada para nombrar/contextualizar las capas.
        bounds_path (str): Ruta o URL del GeoJSON del bounding box (default: ESR_PATH).

    Returns:
        leafmap.Map: Mapa interactivo con las capas de clorofila-a, TSI y vector ESR.
    """

    m = leafmap.Map(zoom=20, basemap="Esri.WorldImagery")

    # --- Capa de clorofila-a ---
    m.add_raster(
        chla_path,
        layer_name=f'Cl-a - {date}',
        palette="Greens",
        nodata=np.nan,
        colormap=True,
    )

    m.add_colormap(
        cmap="Greens",
        vmin=np.nanpercentile(chla_map, 1),
        vmax=np.nanpercentile(chla_map, 99),
        label="Clorofila-a"
    )

    # --- Capa de TSI ---
    colors = [
        "#2c7bb6",
        "#abd9e9",
        "#ffffbf",
        "#fdae61",
        "#d7191c"
    ]
    cmap = ListedColormap(colors)

    bounds = np.arange(-0.5, 5.5, 1)  # 5 clases de TSI: 0-4
    norm = BoundaryNorm(bounds, cmap.N)

    m.add_raster(
        tsi_path,
        layer_name= f'TSI-{date}',
        colormap=cmap,
        vmin=0,
        vmax=4,
        norm=norm,
        nodata=np.nan
    )

    m.add_legend(
        title="Índice de Carlson (TSI)",
        labels=[
            "Ultraoligotrófico",
            "Oligotrófico",
            "Mesotrófico",
            "Eutrófico",
            "Hipertrófico"
        ],
        fontsize=18,
        colors=colors
    )

    # --- Capa ESR ---
    esr_gdf = gpd.read_file(ESR_PATH)
    m.add_gdf(esr_gdf, layer_name='Límites ESR', style={'color': 'yellow', 'weight': 2, 'fillOpacity': 0})

    return m # Display del mapa interactivo
