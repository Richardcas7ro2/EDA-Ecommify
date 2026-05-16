# Preparación de Datos (PostgreSQL Avanzado) en Colab

Lamentablemente, el servidor MCP que enlaza directamente con Colab experimentó una interrupción (`EOF`), por lo que no puedo inyectar este código directamente en tu cuaderno activo. 

Sin embargo, a continuación te proveo el **código Python / Pandas** que debes pegar en una celda de tu Colab para realizar la transformación de los datos hacia los tipos avanzados requeridos por PostgreSQL (JSONB, Arrays, PostGIS).

### 1. Cargar las librerías necesarias
```python
import pandas as pd
import json
import numpy as np
```

### 2. Transformación de Productos (Para JSONB y Arrays)
Vamos a simular que unimos la tabla de productos con la tabla de traducciones (o que convertimos sus medidas en un JSON).

```python
# Cargar CSV
# df_products = pd.read_csv('olist_products_dataset.csv')

def transform_products(df):
    # Crear la estructura JSONB para 'specifications'
    # Agrupamos dimensiones y peso en un solo diccionario por fila
    df['specifications'] = df.apply(lambda row: json.dumps({
        'weight_g': row.get('product_weight_g'),
        'dimensions': {
            'length_cm': row.get('product_length_cm'),
            'height_cm': row.get('product_height_cm'),
            'width_cm': row.get('product_width_cm')
        }
    }), axis=1)
    
    # Crear un Array (simulado) para las fotos
    # En PostgreSQL usaremos TEXT[], en Pandas lo dejamos como lista convertida a string para el CSV
    df['photos'] = df.apply(lambda row: f"{{photo_{row['product_id']}_1.jpg}}" if pd.notnull(row.get('product_photos_qty')) and row['product_photos_qty'] > 0 else "{}", axis=1)
    
    # Mantener las columnas relevantes
    df_clean = df[['product_id', 'product_category_name', 'specifications', 'photos']]
    return df_clean

# Ejecución
# df_products_clean = transform_products(df_products)
# df_products_clean.to_csv('products_clean.csv', index=False)
```

### 3. Transformación de Geolocalización (Para PostGIS)
Para la tabla de geolocalización, necesitamos preparar las coordenadas de tal forma que luego en PostgreSQL podamos inyectarlas como puntos espaciales.

```python
# df_geo = pd.read_csv('olist_geolocation_dataset.csv')

def transform_geolocation(df):
    # Olist tiene muchos zips repetidos con ligeras variaciones de lat/lng. 
    # Agrupamos por zip y promediamos la lat/lng para tener una relación 1 a 1.
    df_clean = df.groupby('geolocation_zip_code_prefix').agg({
        'geolocation_lat': 'mean',
        'geolocation_lng': 'mean',
        'geolocation_city': 'first',
        'geolocation_state': 'first'
    }).reset_index()
    
    # Renombrar columnas para nuestro esquema
    df_clean.columns = ['zip_code_prefix', 'lat', 'lng', 'city', 'state']
    
    # En SQL, ejecutaremos la conversión:
    # UPDATE geolocation SET geom = ST_SetSRID(ST_MakePoint(lng, lat), 4326);
    return df_clean

# df_geo_clean = transform_geolocation(df_geo)
# df_geo_clean.to_csv('geolocation_clean.csv', index=False)
```

### Instrucciones
1. Ejecuta este código en tu Google Colab tras haber subido tus `.csv` desde Google Drive.
2. Exporta los resultados limpios a un nuevo CSV.
3. Importa esos CSV a Supabase/PostgreSQL, y los campos JSON y Array serán reconocidos.
