# Ecommify - Diseño Conceptual y logico.

Este repositorio contiene la entrega de la actividad 2 de la asignatura de Diseño y Optimización de Bases de Datos de la Maestria en Arquitectura de software.

## 👥 Integrantes del Equipo (Grupo 9)
*   **Abdul Mauricio Reyes Parra**
*   **Jorge Esteban Triviño Correa**
*   **Jorge Rolando Maradey Duran**
*   **Wilmer Ricardo Castro Delgadillo**

## 📝 Descripción del Proyecto
Este proyecto aborda el diseño conceptual y lógico de la base de datos de "Ecommify", una plataforma de comercio electrónico multivendedor (basada en el dataset de Olist). El diseño adopta una **Arquitectura Híbrida** para maximizar el rendimiento:
1.  **Módulo Transaccional (PostgreSQL):** Modelo relacional normalizado hasta la Tercera Forma Normal (3FN) con cumplimiento ACID para operaciones críticas como pedidos y pagos. Hace uso intensivo de tipos avanzados (`JSONB`, `ARRAY`) y extensiones geospaciales (`PostGIS`) y trigramáticas (`pg_trgm`).
2.  **Módulo NoSQL (MongoDB):** Modelo documental orientado a alta disponibilidad para el catálogo de productos y registros de comportamiento analítico de usuarios, mitigando la carga de lectura del motor transaccional.

## 📂 Estructura del Repositorio

De acuerdo con las instrucciones estrictas de la Guía de Actividades, el repositorio está estructurado de la siguiente manera:

```text
Ecommify_Database_Design/
├── README.md                           # Este archivo de documentación principal.
├── docs/                               # Documentación técnica generada.
│   ├── Documento_Tecnico_Diseno.pdf    # Documento técnico consolidado con el análisis completo.
│   └── Presentacion_Ejecutiva.pdf      # Presentación resumida del diseño híbrido y justificaciones.
├── postgresql/                         # Diseño relacional y transaccional.
│   ├── schema/                         # Scripts DDL para la creación de tablas (ej. 01_ddl_tables.sql).
│   ├── seed_data/                      # Directorio preparado para los scripts de inserción de datos semilla.
│   └── queries/                        # Directorio preparado para los scripts de consultas analíticas DML.
├── mongodb/                            # Diseño documental NoSQL.
│   └── schema/                         # Archivos JSON que modelan las colecciones (ej. collections_schema.json).
└── notebooks/                          # Análisis exploratorio y preparación de datos.
    └── Data_Exploration_Analysis.ipynb # Jupyter notebook con el Análisis Exploratorio de Datos (EDA).
```

*Nota: Los directorios `seed_data` y `queries` se mantienen inicializados para el desarrollo de las siguientes fases de la actividad.*
