# Matriz de Decisión y Análisis del Teorema CAP

En la arquitectura híbrida diseñada para Ecommify, es crucial definir claramente qué responsabilidades asume cada motor de base de datos. Para esto, nos basamos en el **Teorema CAP** (Consistencia, Disponibilidad, Tolerancia a Particiones).

## Análisis del Teorema CAP

*   **PostgreSQL (Módulo Transaccional):** Se prioriza **CP** (Consistencia y Tolerancia a Particiones). Es crítico que los pedidos, los pagos y el inventario mantengan integridad transaccional (ACID). No podemos permitir que un cliente pague por un producto que acaba de agotarse.
*   **MongoDB (Módulo Analítico y Catálogo):** Se prioriza **AP** (Disponibilidad y Tolerancia a Particiones). Para el catálogo de productos y la visualización de reseñas, es más importante que el sistema esté disponible y rápido, incluso si la información tarda unos milisegundos en ser consistente (Eventual Consistency).

## Matriz de Decisión

| Entidad/Módulo | Tecnología Elegida | Justificación Técnica | Atributos Críticos del Teorema CAP |
| :--- | :--- | :--- | :--- |
| **Pedidos (Orders)** | PostgreSQL | Requiere transacciones ACID para evitar inconsistencias en las compras y los estados de los pedidos. Alta integridad referencial. | **CP:** Consistencia estricta para compras. |
| **Pagos (Payments)** | PostgreSQL | El procesamiento financiero no tolera pérdida de datos ni eventual consistency. Debe relacionarse estrictamente con el pedido. | **CP:** Seguridad financiera y transaccional. |
| **Geolocalización** | PostgreSQL | Permite el uso de la extensión `PostGIS` para análisis geoespacial de envíos de forma nativa e integrada al modelo. | **CP / SQL Avanzado** |
| **Catálogo de Prod.** | MongoDB | Los productos tienen estructuras variables (electrónica vs ropa tienen specs distintos). MongoDB con su formato BSON/JSON es ideal. | **AP:** Alta disponibilidad para búsquedas. |
| **Reseñas (Reviews)** | MongoDB | Las reseñas son documentos semiestructurados y de alto volumen de lectura. No necesitan transaccionalidad estricta con los pedidos. | **AP:** Lectura intensiva y escalabilidad. |
| **Log de Eventos** | MongoDB | Para registrar el comportamiento del usuario (clics, carritos abandonados). Estructura dinámica y alto volumen de escritura rápida. | **AP:** Inserción masiva sin bloqueo. |

## Estrategia de Sincronización

1.  El catálogo principal se crea en PostgreSQL con datos básicos (ID, Precio, Stock).
2.  Un sistema de *Change Data Capture* (CDC), como Debezium, puede escuchar los cambios en PostgreSQL y replicar el catálogo detallado hacia MongoDB, donde se enriquecerá con las reseñas y atributos variables.
