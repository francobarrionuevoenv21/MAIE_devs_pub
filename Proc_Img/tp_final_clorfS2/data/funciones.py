# --
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

# --

def get_bounds_4326(vector_path):
    '''
    --
    '''
    
    vector_gdf = gpd.read_file(vector_path).to_crs(epsg=4326)

    return vector_gdf.total_bounds # minx, miny, maxx, maxy

def df_items(stac_items):

    # Lista de las propiedades a extraer de cada item
    properties_to_extract = [
        "datetime",
        "platform",
        "eo:cloud_cover",
    ]

    # --
    data = []
    for item in stac_items:
        row = {}
        for prop in properties_to_extract: # Obtener el valor de la propiedad o None si no está presente
            if prop == 'datetime':
                row[prop] = item.properties.get(prop, None)[:10] # Just keep the date
            else:
                row[prop] = item.properties.get(prop, None)
        data.append(row)

    return pd.DataFrame(data)\
        .rename(columns={'datetime': 'Fecha', 
                        'platform': 'Plataforma', 
                        'eo:cloud_cover': 'Cloud Cover (%)'})

def explore_s2_items(date_ini, date_end, cv):

    # Import bounding box desde GitHub
    minx, miny, maxx, maxy = get_bounds_4326('https://github.com/francobarrionuevoenv21/MAIE_devs_pub/raw/refs/heads/main/Proc_Img/tp_final_clorfS2/data/esr_clean.geojson')

    # URL actualizada del catálogo STAC
    STAC_URL = 'https://earth-search.aws.element84.com/v1' # Catálogo: https://stacindex.org/catalogs?access=protected&type=static#/

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

def down_assets(items, item_id, assets_folder, assets_down = ['red', 'nir']):
        
    '''
    assas
    '''

    # --
    sel_item = items[item_id]

    # Extraemos información clave del elemento: Extraer fecha (YYYY-MM-DD) y grid_code,
    datetime = sel_item.properties.get("datetime", "Error") # Check "Error" param value
    date_yymmdd = datetime[:10]  # 'YYYY-MM-DD'
    platform = sel_item.properties.get("platform", "Error")
    pltf_code = platform[-2:]

    # --
    dict_path_bands = {}

    # Recorremos los assets del ítem
    for asset_key, asset_data in sel_item.assets.items(): # Iteramos sobre los assets de cada imagen
        #print(sel_item.id)
        # Verificamos si es uno de los assets deseados
        if asset_key in assets_down:
            url = asset_data.href

            # --
            dict_path_bands[asset_key] = {'pltf_code': pltf_code, 'date_yymmdd': date_yymmdd}

            # Construimos el nombre del archivo
            filename = f'S{pltf_code}_{date_yymmdd}_{asset_key}.tif'
            out_file = os.path.join(assets_folder, filename)

            print(f"Descargando {asset_key} -> {out_file} ...")
            response = requests.get(url, stream=True) # Descarga el archivo en modo streaming

            with open(out_file, "wb") as f:
                f.write(response.content)

            print(f"Descarga completada: {out_file}")

    print("Descargas completadas.")

    return dict_path_bands

def clip_bands_bounds(assets_folder, dict_path_bands, assets_clip = ['red', 'nir']):

    # --
    bounds_gdf = gpd.read_file('https://github.com/francobarrionuevoenv21/MAIE_devs_pub/raw/refs/heads/main/Proc_Img/tp_final_clorfS2/data/esr_clean.geojson').dissolve()
    bounds_gdf_32720 = bounds_gdf.to_crs(epsg=32720)

    # Guardadod de los dataarrays de los bandas subseteadas en un diccionario
    dict_bands_bounds = {} # Creo un diccionario para subset de bandas + ventanas + nodata

    # Itero sobre la lista de paths para cada de las bandas y las almaceno en el diccionario
    for i, asset in enumerate(assets_clip):

        # --
        band_ds = rio.open(os.path.join(assets_folder, 
                    f'S{dict_path_bands[asset]['pltf_code']}_{dict_path_bands[asset]['date_yymmdd']}_{asset}.tif'))

        band_mask, mask_transform = mask(dataset = band_ds, shapes = bounds_gdf_32720.geometry, nodata=None, crop = True)

        # Extraigo y actualizo metadatos
        bands_meta = band_ds.meta
        bands_meta.update({
                'height': band_mask.shape[1],
                'width': band_mask.shape[2],
                'transform': mask_transform,
                'nodata': None
            })

        dict_bands_bounds[asset] = {'subset' : band_mask[0], # Me quedo con el dataarray en 2D
                                    'metadatos' : bands_meta,
                                    'date': dict_path_bands[asset]['date_yymmdd']}

    return dict_bands_bounds

def calc_chla(dict_clip_bands):
    #--

    #--
    red_data = dict_clip_bands['red']['subset']
    nir_data = dict_clip_bands['nir']['subset']

    #--
    chla_da = -5.57+80.13*(nir_data/red_data)
    chla_da = np.clip(chla_da, 2.8, 288.5) # Defino límites según German et al. (2021)

    return chla_da, dict_clip_bands['red']['date']


def carlson_idx(chla_da):

    # --
    bins = [20, 40, 50, 70]

    tsi_map_raw = np.full_like(chla_da, np.nan, dtype=float)

    # --
    mask = chla_da > 0
    tsi_map_raw[mask] = 9.81 * np.log(chla_da[mask]) + 30.6

    tsi_map_class = np.full(chla_da.shape, -1, dtype=int)
    tsi_map_class[mask] = np.digitize(tsi_map_raw[mask], bins)

    # --
    tsi_map_class = np.where(tsi_map_class==-1, np.nan, tsi_map_class)

    # --
    return tsi_map_class

def comp_maps(dict_clip_bands):

    # --
    chla_map, date = calc_chla(dict_clip_bands)
    tsi_map = carlson_idx(chla_map)

    return chla_map, tsi_map, date

def save_maps(maps_folder, chla_map, tsi_map, dic_clip_bands):

    # --
    chla_path = os.path.join(maps_folder, f'S2_CHLA_{dic_clip_bands['red']['date']}.tif')
    tsi_path = os.path.join(maps_folder, f'S2_TSI_{dic_clip_bands['red']['date']}.tif')

    # --
    list_paths = [chla_path, tsi_path]


    # --
    # Extraigo y actualizo metadatos
    bands_meta = dic_clip_bands['red']['metadatos'] # Extraigo la metadata desde el da de la banda red

    # --
    meta_chla_map = bands_meta.copy()
    meta_chla_map.update({'dtype': 'float32'})

    # --
    with rio.open(
        chla_path, 'w',**meta_chla_map) as dst01:
        dst01.write(chla_map, 1)   # escribir en la banda 1
        dst01.set_band_description(1, 'chla_ug-l')

    # --
    with rio.open(
        tsi_path, 'w',**bands_meta) as dst02:
        dst02.write(tsi_map, 1)   # escribir en la banda 1
        dst02.set_band_description(1, 'carlson_idx')

    return list_paths

def run_chla_s2(items, item_id, assets_folder, maps_folder):

    # --
    print('RUN PASO 1: DESCARGA DE LOS ASSETS DE SENTINEL-2')
    dict_path_bands = down_assets(items, item_id, assets_folder)
    print('END PASO 1')

    # --
    print('\n')
    print('RUN PASO 2: CLIPEADO DE LAS BANDAS')
    dict_clip_bands = clip_bands_bounds(assets_folder, dict_path_bands)
    print('END PASO 2')

    # --
    print('\n')
    print('RUN PASO 3: CÓMPUTO DE LOS MAPAS DE CHL-A Y CARLSON INDEX')
    chla_map, tsi_map, date = comp_maps(dict_clip_bands)
    print('END PASO 3')

    # --
    print('\n')
    print('RUN PASO 4: GUARDADO DE LOS MAPAS COMO EN FORMATO .TIF')
    list_maps = save_maps(maps_folder, chla_map, tsi_map, dict_clip_bands)
    print('END PASO 4')

    return ({'chla_map': chla_map, 'tsi_map': tsi_map, 'date': date},
        list_maps)


def plot_maps(chla_map, tsi_map, date, figsize=(8, 6)):

    fig, ax = plt.subplots(1, 2, figsize=figsize, constrained_layout=True)

    # ======================
    # CHLOROPHYLL MAP
    # ======================

    cmap = cm.get_cmap('BuGn').copy()
    cmap.set_bad(color="#6B544C92")

    im1 = ax[0].imshow(
        np.ma.masked_invalid(chla_map),
        cmap=cmap,
        vmin=np.nanpercentile(chla_map, 1),
        vmax=np.nanpercentile(chla_map, 99)
    )

    ax[0].set_title(f'Estimación concentración\nCl-a {date}', fontsize = 12)
    ax[0].set_axis_off()

    divider = make_axes_locatable(ax[0])
    cax1 = divider.append_axes("right", size="5%", pad=0.05)

    fig.colorbar(
        im1,
        cax=cax1,
        label="Concentración de clorofila [$\mu$$g/L$]"
    )

    # ======================
    # TSI MAP
    # ======================

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

    ax[1].set_title(f'Índice de Carlson (TSI)\n{date}', fontsize = 12)
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
