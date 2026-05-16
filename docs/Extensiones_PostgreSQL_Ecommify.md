# Justificación de Extensiones de PostgreSQL para Ecommify

En el contexto de la optimización del diseño relacional avanzado para la plataforma de comercio electrónico Ecommify, y con el propósito de mejorar tanto el rendimiento como las capacidades funcionales del sistema híbrido, se ha determinado la incorporación de extensiones específicas de PostgreSQL. 

A continuación, se presenta la evaluación y justificación técnica para el uso de **PostGIS** y **pg_trgm**.

## 1. PostGIS (Datos Geoespaciales)

**Descripción:**  
PostGIS es una extensión que añade soporte para objetos geográficos a la base de datos relacional PostgreSQL, permitiendo ejecutar consultas de ubicación de manera espacial mediante SQL.

**Caso de Uso en Ecommify:**  
El dataset *Brazilian E-commerce (Olist)* contiene información valiosa de geolocalización (códigos postales, latitud y longitud) tanto de clientes como de vendedores (`geolocation`). 

**Aplicabilidad:**  
- **Optimización y Cálculo de Costos de Envío:** En lugar de depender de servicios externos o aproximaciones básicas, podemos usar tipos de datos `geometry` o `geography` para calcular la distancia exacta (en metros o kilómetros) entre el vendedor (seller) y el cliente (customer) utilizando funciones nativas como `ST_Distance`.
- **Análisis de Cobertura:** Permite visualizar y analizar cuáles son las zonas con mayor concentración de pedidos y relacionarlo con los tiempos de entrega, mejorando la logística general.

**Decisión Técnica:**  
Se habilita `PostGIS` para la tabla de geolocalización, creando una columna de tipo `Point` que almacenará la latitud y longitud. Esto se indexará usando un índice espacial (GIST), lo que acelerará exponencialmente las búsquedas por radio de cercanía o cálculo de rutas.

---

## 2. pg_trgm (Búsqueda de Texto Tolerante a Errores)

**Descripción:**  
El módulo `pg_trgm` proporciona funciones y operadores para determinar la similitud de texto alfanumérico basándose en el conteo de trigramas (grupos de tres caracteres consecutivos). Además, soporta índices para búsquedas rápidas.

**Caso de Uso en Ecommify:**  
En cualquier e-commerce, el buscador de productos es una de las funcionalidades críticas. Los usuarios a menudo cometen errores tipográficos al buscar nombres de productos (ej. buscar "smarphone" en lugar de "smartphone") o categorías (`product_category_name`).

**Aplicabilidad:**  
- **Búsquedas de Productos ("Fuzzy Search"):** Al aplicar un índice GIN o GiST con `pg_trgm` sobre la columna del nombre o descripción del producto, Ecommify podrá retornar resultados precisos incluso cuando el usuario cometa pequeños errores ortográficos.
- **Autocompletado Rápido:** Mejora el rendimiento del autocompletado en la barra de búsqueda en comparación con el uso estándar del operador `LIKE '%texto%'`, el cual no aprovecha índices en búsquedas con comodines iniciales.

**Decisión Técnica:**  
Se habilita `pg_trgm` para la base de datos. Se creará un índice GIN en la tabla de productos (específicamente en el nombre/título del producto) para mejorar el rendimiento de las consultas de búsqueda del catálogo y sugerencias de productos.
