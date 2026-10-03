"""
Build the model inputs for Embalse San Roque.

Usage
-----
    from get_inputs import run
    df_input, ds_chla = run('2026-09-29')
"""

import glob
import os
import warnings
import zipfile

import cdsapi
import geopandas as gpd
import numpy as np
import pandas as pd
import pystac_client
import rioxarray  # noqa: F401  (registers the .rio accessor)
import xarray as xr
from odc.stac import load

warnings.filterwarnings('ignore', message='Could not parse bucket/account from href')

ESR_PATH = (
    'https://github.com/francobarrionuevoenv21/MAIE_devs_pub/'
    'raw/refs/heads/main/Proc_Img/tp_final_claS2/data/esr_clean.geojson'
)

MASK_PATH = (
    'https://raw.githubusercontent.com/francobarrionuevoenv21/MAIE_devs_pub/'
    'main/Modelos/TPfinal_ESRTTSS_pred/output/esr_mask.nc'
)

ARCV_ZIP = 'data_era5_'


class NoScenesError(ValueError):
    """Raised when no Sentinel-2 scene is found for the requested dates."""

# How many days back from date_ini to look for the last available Sentinel-2 image
LOOKBACK_DAYS = 3


# ---------------------------------------------------------------------------
# Dates
# ---------------------------------------------------------------------------
def compute_dates(date_ini):
    """Return the reference dates 7, 14 and 28 days before date_ini."""
    date_7d_before = date_ini - np.timedelta64(7, 'D')
    date_14d_before = date_ini - np.timedelta64(14, 'D')
    date_28d_before = date_ini - np.timedelta64(28, 'D')
    return date_7d_before, date_14d_before, date_28d_before


# ---------------------------------------------------------------------------
# Sentinel-2 / chlorophyll-a
# ---------------------------------------------------------------------------
def get_s2_ds(date_ini, date_end, cv=30, last_only=False):
    """
    Busca ítems Sentinel-2 L2A en el catálogo STAC de AWS Earth Search
    dentro de un bounding box y rango de fechas.
    Si last_only=True, se queda solo con la fecha más reciente encontrada.
    """

    # Import bounding box desde GitHub
    minx, miny, maxx, maxy = gpd.read_file(ESR_PATH)\
        .to_crs(epsg=4326)\
        .total_bounds

    # Crea un cliente STAC usando la URL del catálogo
    catalog = pystac_client.Client.open(
        'https://earth-search.aws.element84.com/v1'
    )

    # Define los parámetros de la búsqueda
    search = catalog.search(
        collections=['sentinel-2-c1-l2a'],
        bbox=[minx, miny, maxx, maxy],
        datetime=f'{date_ini}T00:00:00Z/{date_end}T23:59:59Z',
        sortby=[
            {
                "field": "properties.datetime",
                "direction": "asc"
            }
        ],
        query={
            'eo:cloud_cover': {'lt': cv},
        }
    )

    # Save items
    items = search.item_collection()

    # Load to XArray
    if len(items) > 0:

        # Keep only the most recent date (items are sorted ascending)
        if last_only:
            last_day = items[-1].datetime.date()
            items = [i for i in items if i.datetime.date() == last_day]

        # Print cantidad de elementos
        print(f'Sentinel-2 scenes found: {len(items)}')

        ds_2a = load(
            items,
            bands=['red', 'nir', 'scl'],
            bbox=[minx, miny, maxx, maxy],
            resolution=10,
            crs='EPSG:32720',
            groupby='solar_day',
            preserve_original_order=True
        )

        return ds_2a

    else:
        print('Not Sentinel-2 scenes available')
        return None


def get_chla_lag1(date_ini, date_end, cv=30, last_only=False):
    """
    Calculate chlorophyll-a from Sentinel-2 L2A imagery for Embalse San Roque.

    Parameters
    ----------
    date_ini : str
        Start date of the Sentinel-2 search.
    date_end : str
        End date of the Sentinel-2 search.
    cv : float
        Maximum allowed scene-level cloud cover (%).
    last_only : bool
        If True, use only the most recent image found in the date range.

    Returns
    -------
    da_chla : xarray.DataArray
        Chlorophyll-a estimates (named 'chla') for each pixel.
    esr_value : xarray.DataArray
        Median chlorophyll-a value over the reservoir.
    """

    # -- Get Sentinel-2 L2A images for the requested date range
    ds_s2 = get_s2_ds(date_ini, date_end, cv, last_only)

    if ds_s2 is None:
        raise NoScenesError(
            f'No Sentinel-2 scenes found between {date_ini} and {date_end} '
            f'(cloud cover < {cv}%).'
        )

    # -- Reproject the Embalse San Roque geometry to the CRS of the Sentinel-2 data
    esr_reprj = gpd.read_file(ESR_PATH).to_crs('EPSG:32720')
    esr_reprj = esr_reprj[~esr_reprj.geometry.is_empty]  # drop empty geometries

    # -- Clip the Sentinel-2 dataset to the Embalse San Roque area
    ds_s2 = ds_s2.rio.clip(esr_reprj.geometry)

    # -- Apply scale/offset to convert Sentinel-2 values to surface reflectance
    scale = 0.0001
    offset = -0.1

    # -- Select spectral bands required for the chlorophyll-a model
    data_bands = ['red', 'nir']

    for band in data_bands:
        ds_s2[band] = ds_s2[band] * scale + offset

    # -- Remove pixels classified as cloud shadow, clouds and cirrus using the SCL band
    ds_s2 = ds_s2.where(~ds_s2.scl.isin([3, 8, 9, 10]))

    # -- Load the previously generated mask for valid pixels within the ESR
    # The mask was saved from an unnamed DataArray, so it has xarray's default name
    mask = xr.open_dataset(MASK_PATH)['__xarray_dataarray_variable__']

    # -- Calculate chlorophyll-a from the NIR/Red reflectance ratio
    da_chla = -5.57 + 80.13 * (ds_s2['nir'] / ds_s2['red'])

    # -- Limit the predicted chlorophyll-a values to the range of the model
    da_chla = da_chla.clip(2.8, 288.5)

    # -- Resample the ESR mask to the Sentinel-2 grid
    mask = mask.interp(
        x=da_chla.x,
        y=da_chla.y,
        method='nearest'
    )

    # -- Apply the ESR mask
    da_chla = da_chla.where(mask == 1)

    # -- Check: valid pixels per scene (after cloud + ESR mask)
    n_esr = int((mask == 1).sum())
    valid_pct = da_chla.notnull().sum(dim=['x', 'y']) / n_esr * 100
    print(f'[S2] Period: {date_ini} to {date_end} | scenes used: {da_chla.sizes["time"]}')
    print(f'[S2] Grid: {da_chla.sizes["y"]} x {da_chla.sizes["x"]} px | ESR pixels: {n_esr}')
    for t, v in zip(da_chla.time.values, valid_pct.values):
        print(f'[S2]   {str(t)[:10]}: {v:.1f}% valid ESR pixels')

    if float(valid_pct.max()) == 0:
        raise ValueError('[S2] All ESR pixels are masked (clouds or mask mismatch).')

    scene_dates = ','.join(str(t)[:10] for t in da_chla.time.values)

    # -- Median over time (one image for the whole period)
    da_chla = da_chla.median(dim='time')
    da_chla.attrs['scene_dates'] = scene_dates

    # -- Set DataArray name
    da_chla.name = 'chla'

    # -- Calculate the median chlorophyll-a value for the entire ESR
    esr_value = da_chla.median(dim=['x', 'y'])

    # -- Check: final chlorophyll-a values
    if np.isnan(esr_value.item()):
        raise ValueError('[S2] ESR median chlorophyll-a is NaN.')

    print(
        f'[S2] chla (ug/L) min/median/max: '
        f'{float(da_chla.min()):.1f} / {esr_value.item():.1f} / {float(da_chla.max()):.1f}'
    )
    print(f'[S2] OK - ESR median chlorophyll-a = {esr_value.item():.2f}')

    return da_chla, esr_value


# ---------------------------------------------------------------------------
# ERA5-Land
# ---------------------------------------------------------------------------
def get_era5_ds(date_ini, date_end, arcv_zip=ARCV_ZIP):
    """
    Download ERA5-Land 2m temperature and surface solar radiation as a zip,
    extract it and return a single merged Dataset.
    """
    
    # Update arcv_zip
    arcv_zip = arcv_zip + str(date_end)

    client = cdsapi.Client()

    dataset = "reanalysis-era5-land-timeseries"
    request = {
        "variable": [
            "2m_temperature",
            "surface_solar_radiation_downwards",
        ],
        "date": [f'{date_ini}/{date_end}'],
        "data_format": "netcdf",
        "area": [-31.2, -64.6, -31.5, -64.3],
        "download_format": "zip",
    }

    client.retrieve(dataset, request).download(f'{arcv_zip}.zip')
    print(f'[ERA5] Zip downloaded: {arcv_zip}.zip ({os.path.getsize(f"{arcv_zip}.zip") / 1024:.1f} KB)')

    # -- Extract ZIP
    with zipfile.ZipFile(f'{arcv_zip}.zip') as z:
        z.extractall(arcv_zip)

    # -- Find NetCDF files
    files = glob.glob(f'{arcv_zip}/*.nc')
    print(f'[ERA5] Files extracted: {[os.path.basename(f) for f in files]}')

    # -- Open the two NetCDF files
    ds_ssrd = xr.open_dataset([f for f in files if 'radiation' in f][0])
    ds_t2m = xr.open_dataset([f for f in files if '2m-temperature' in f][0])

    # -- Merge into a single Dataset
    ds_era = xr.merge([ds_ssrd, ds_t2m])

    # -- Check: variables, time range and missing values
    for var in ['t2m', 'ssrd']:
        if var not in ds_era:
            raise ValueError(f'[ERA5] Variable {var} not found in the downloaded data.')

    times = ds_era['valid_time'].values
    print(f'[ERA5] Variables: {list(ds_era.data_vars)}')
    print(f'[ERA5] Period: {str(times.min())[:10]} to {str(times.max())[:10]} | timesteps: {len(times)}')
    print(
        f'[ERA5] NaN values -> t2m: {int(ds_era["t2m"].isnull().sum())}, '
        f'ssrd: {int(ds_era["ssrd"].isnull().sum())}'
    )

    return ds_era


def get_era5_daily(ds_era):
    """
    Compute daily temperature (mean) and radiation (max of the accumulation)
    from the ERA5-Land Dataset.
    """

    # -- Select variables
    t2m = ds_era['t2m']
    ssrd = ds_era['ssrd']

    t2m_medn = t2m.median(dim=['latitude', 'longitude'])
    ssrd_medn = ssrd.median(dim=['latitude', 'longitude'])

    t2m_daily = t2m_medn.resample(valid_time='1D').mean()
    t2m_daily_values = t2m_daily.values[1:]
    ssrd_daily_values = ssrd_medn.resample(valid_time='1D').max().values[1:]

    era5_dates = t2m_daily.valid_time.values.astype('datetime64[D]')[1:]

    # -- Check: daily series
    print(f'[ERA5] Daily values: {len(era5_dates)} days ({era5_dates[0]} to {era5_dates[-1]})')
    print(f'[ERA5] t2m daily mean range: {t2m_daily_values.min() - 273.15:.1f} to {t2m_daily_values.max() - 273.15:.1f} C')
    print(f'[ERA5] ssrd daily max range: {ssrd_daily_values.min():.0f} to {ssrd_daily_values.max():.0f} J/m2')

    if np.isnan(t2m_daily_values).any() or np.isnan(ssrd_daily_values).any():
        raise ValueError('[ERA5] NaN values found in the daily series.')

    return era5_dates, t2m_daily_values, ssrd_daily_values


# ---------------------------------------------------------------------------
# Final input table
# ---------------------------------------------------------------------------
def build_df_input(era5_dates, t2m_daily_values, ssrd_daily_values, esr_value):
    """Build the weekly lagged input row for the model."""

    df_input_daily = pd.DataFrame()

    df_input_daily['fecha'] = pd.to_datetime(era5_dates)
    df_input_daily = df_input_daily.set_index('fecha').sort_index()
    df_input_daily['temperatura'] = t2m_daily_values
    df_input_daily['radiacion'] = ssrd_daily_values

    df_input_semanal = df_input_daily.resample('W').agg(
        {'temperatura': 'mean', 'radiacion': 'sum'}
    )

    df_input_lag = df_input_semanal.copy()

    for col in df_input_lag.columns:
        df_input_lag[f'{col}_lag{3}'] = df_input_lag[col].shift(1)

    df_input_lag = df_input_lag.rename(
        columns={'temperatura': 'temperatura_lag2', 'radiacion': 'radiacion_lag2'}
    )

    df_input = df_input_lag.dropna().copy()
    df_input['cla_lag1'] = esr_value.item()

    df_input = df_input.iloc[-1]

    return df_input


# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------
def run(date_ini):
    """
    Parameters
    ----------
    date_ini : str
        Reference date as 'YYYY-MM-DD', e.g. '2026-09-29'.

    Returns
    -------
    df_input : pandas.Series
        Model inputs (last weekly row).
    ds_chla : xarray.DataArray or None
        Chlorophyll-a map (named 'chla') of the last available Sentinel-2
        image up to date_ini (used for validation). The image date is in
        ds_chla.attrs['scene_dates']. None if no image is available.
    """

    # -- Convert the input string to datetime64
    date_ini = np.datetime64(date_ini)

    date_7d_before, date_14d_before, date_28d_before = compute_dates(date_ini)

    # -- Sentinel-2 chlorophyll-a for prediction: 14 to 7 days before date_ini
    _, esr_value = get_chla_lag1(date_14d_before, date_7d_before)

    # -- Sentinel-2 chlorophyll-a for validation: last available image up to date_ini
    date_lookback = date_ini - np.timedelta64(LOOKBACK_DAYS, 'D')
    try:
        ds_chla, _ = get_chla_lag1(date_lookback, date_ini, last_only=True)
        print(f"[S2] Validation image date: {ds_chla.attrs['scene_dates']}")
    except NoScenesError:
        ds_chla = None
        print(
            f'[S2] No images available in the last {LOOKBACK_DAYS} days '
            f'({date_lookback} to {date_ini}). Validation skipped.'
        )

    # -- ERA5-Land meteorology
    ds_era = get_era5_ds(date_28d_before, date_14d_before)
    era5_dates, t2m_daily_values, ssrd_daily_values = get_era5_daily(ds_era)

    # -- Final input
    df_input = build_df_input(
        era5_dates, t2m_daily_values, ssrd_daily_values, esr_value
    )

    return df_input, ds_chla
