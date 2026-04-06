
----
- IC4302 - Bases de Datos II
- Gerardo Nereo Campos Araya
- Integrantes:
     + Andrés Martínez Fumero
     + Fabian Flores Alvarado
     + Felix Morales Cerdas
     + Oscar Bezara Perez
     + Javier Rodríguez Menjívar
-----------------------------
# Descripción general

Se realizaron pruebas en las seis bases de datos principales usando Gatling 3.15.0 como herramienta de carga.  Todas las pruebas se ejecutaron contra una API REST expuesta en `http://localhost:30500`, la cual actúa como intermediaria entre Gatling y cada motor de base de datos
Las operaciones evaluadas fueron **Create (POST), Read (GET), Update (PUT) y Delete (DELETE)**, cubriendo el ciclo CRUD completo.

# Dataset
El dataset utilizado consiste en registros de **usuarios** con los siguientes campos según la base de datos:

| Base de datos | Campos usados    |
| ------------- | ---------------- |
| MongoDB       | `nombre`,`email` |
| CouchDB       | `nombre`,`email` |
| Redis         | `usuario`,`rol`  |
| ElasticSearch | `nombre`,`email` |
| MariaDB       | `nombre`,`email` |
| PostgreSQL    | `nombre`         |

# MariaDB

**Fecha de ejecución:** 2026-04-05 16:10:18 GMT  
**Duración:** ~30 min  
**Tipo de prueba:** CRUD con escenarios independientes  
**Errores:** 0 (100% OK)

### Resultados

| Métrica | Valor |
|---|---|
| Total requests | 12,220 |
| Mínimo | 27 ms |
| Media | 64 ms |
| p50 | 64 ms |
| p75 | 82 ms |
| p95 | 90 ms |
| p99 | 91 ms |
| Máximo | ~520 ms |
| Throughput | 6.79 req/s |

| Operación | Total | Media (ms) | p95 (ms) |
|---|---|---|---|
| POST /mariadb/users | 6,110 | 79 | 91 |
| GET /mariadb/users | 3,050 | 57 | 91 |
| PUT /mariadb/users/:id | 1,530 | 46 | 71 |
| DELETE /mariadb/users/:id | 1,530 | 46 | 71 |

### Conclusiones
MariaDB fue el motor con el peor rendimiento general, con una media de 64 ms. La operación más costosa fue POST con 79 ms de promedio, dado que implica la inserción y commit transaccional. MariaDB demostró ser el motor menos adecuado para cargas de alta concurrencia de escritura en este contexto.

# Mongo

**Fecha de ejecución:** 2026-04-04 23:06:47 GMT  
**Duración:** 29 min 59 s  
**Tipo de prueba:** CRUD con escenarios independientes  
**Errores:** 0 (100% OK)

### Resultados

| Métrica        | Valor      |
| -------------- | ---------- |
| Total requests | 12,220     |
| Mínimo         | 3 ms       |
| Media          | 13 ms      |
| p50            | 11 ms      |
| p75            | 14 ms      |
| p95            | 26 ms      |
| p99            | 64 ms      |
| Máximo         | 266 ms     |
| Throughput     | 6.79 req/s |

| Operación               | Total | Media (ms) | p95 (ms) |
| ----------------------- | ----- | ---------- | -------- |
| POST /mongo/users       | 6,110 | 11         | 35       |
| GET /mongo/users        | 3,050 | 6          | 10       |
| PUT /mongo/users/:id    | 1,530 | 15         | 27       |
| DELETE /mongo/users/:id | 1,530 | 14         | 23       |

### Conclusion
MongoDB demostró un rendimiento sólido y consistente en todas las operaciones CRUD. El tiempo medio de respuesta global de 13 ms lo posiciona como el segundo motor más rápido entre los evaluados.

# ElasticSearch

**Fecha de ejecución:** 2026-04-05 00:48:58 GMT  
**Duración:** ~30 min  
**Tipo de prueba:** CRUD con escenarios independientes  
**Errores:** 0 (100% OK, 3 requests entre 800-1200 ms: 0.02%)
### Resultados

| Métrica | Valor |
|---|---|
| Total requests | 12,220 |
| Mínimo | 4 ms |
| Media | 11 ms |
| p50 | 10 ms |
| p75 | 13 ms |
| p95 | 18 ms |
| p99 | 24 ms |
| Máximo | 1,054 ms |
| Throughput | 6.79 req/s |

| Operación | Total | Media (ms) | p95 (ms) |
|---|---|---|---|
| POST /elastic/users | 6,110 | 13 | 19 |
| GET /elastic/users | 3,050 | 7 | 10 |
| PUT /elastic/users/:id | 1,530 | 10 | 16 |
| DELETE /elastic/users/:id | 1,530 | 9 | 14 |

### Conclusiones
Elasticsearch obtuvo el segundo mejor rendimiento con una media de 11 ms. La lectura fue la operación más eficiente con 7 ms, aprovechando el índice invertido de Elasticsearch que optimiza las búsquedas.

# CouchDB

**Fecha de ejecución:** 2026-04-04 23:40:18 GMT  
**Duración:** ~30 min  
**Tipo de prueba:** CRUD encadenado secuencial (POST → GET → PUT → DELETE por usuario virtual)  
**Errores:** 0 (100% OK)

### Resultados
| Métrica        | Valor      |
| -------------- | ---------- |
| Total requests | 12,197     |
| Mínimo         | 15 ms      |
| Media          | 30 ms      |
| p50            | 23 ms      |
| p75            | 40 ms      |
| p95            | 56 ms      |
| p99            | 73 ms      |
| Máximo         | 157 ms     |
| Throughput     | 6.78 req/s |

| Operación | Total | Media (ms) | p95 (ms) |
|---|---|---|---|
| POST /couch/users | 3,050 | 19 | 27 |
| GET /couch/users | 3,050 | 49 | 68 |
| PUT /couch/users/:id | 3,049 | 22 | 31 |
| DELETE /couch/users/:id | 3,048 | 23 | 32 |

### Conclusiones
CouchDB presentó un tiempo medio global de 30 ms, lo cual lo coloca en un rango intermedio-lento respecto a los demás motores evaluados. El aspecto más llamativo es que la operación de lectura (GET) fue considerablemente más lenta que las escrituras.

# Redis

**Fecha de ejecución:** 2026-04-05 00:17:18 GMT  
**Duración:** ~30 min  
**Tipo de prueba:** CRUD encadenado secuencial sobre sesiones 
**Errores:** 0 (100% OK)

### Resultados

| Métrica | Valor |
|---|---|
| Total requests | 12,197 |
| Mínimo | 2 ms |
| Media | 4 ms |
| p50 | 4 ms |
| p75 | 4 ms |
| p95 | 5 ms |
| p99 | 10 ms |
| Máximo | 301 ms |
| Throughput | 6.78 req/s |

| Operación | Total | Media (ms) | p95 (ms) |
|---|---|---|---|
| POST /redis/session | 3,050 | 4 | 6 |
| GET /redis/session/:id | 3,050 | 4 | 5 |
| PUT /redis/session/:id | 3,049 | 4 | 6 |
| DELETE /redis/session/:id | 3,048 | 4 | 5 |

### Conclusión
Redis fue el motor con el mejor rendimiento de todos los evaluados, con un tiempo medio de 4 ms y un p95 de apenas 5 ms. Esto se debe a que al operar directamente en RAM, elimina la latencia en disco presente en todos los demás motores. Lo más destacable es la uniformidad total entre operaciones: POST, GET, PUT y DELETE presentaron exactamente el mismo tiempo promedio de 4 ms.

# PostgreSQL

**Fecha de ejecución:** 2026-04-05 17:16:28 GMT  
**Duración:** ~30 min  
**Tipo de prueba:** CRUD con escenarios independientes  
**Errores:** 0 (100% OK)

### Resultados

| Métrica | Valor |
|---|---|
| Total requests | 12,220 |
| Mínimo | 8 ms |
| Media | 28 ms |
| p50 | 28 ms |
| p75 | 102 ms |
| p95 | 174 ms |
| p99 | 199 ms |
| Máximo | 3,478 ms |
| Throughput | 6.79 req/s |

| Operación                  | Total | Media (ms) | p95 (ms) |
| -------------------------- | ----- | ---------- | -------- |
| POST /postgres/users       | 6,110 | 18         | 104      |
| GET /postgres/users        | 3,050 | 11         | 69       |
| PUT /postgres/users/:id    | 1,530 | 104        | 199      |
| DELETE /postgres/users/:id | 1,530 | 105        | 199      |

### Conclusión
PostgreSQL presentó el comportamiento más variable de todos los motores evaluados. Las operaciones más afectadas fueron PUT y DELETE, con promedios de ~104-105 ms, lo que sugiere contención en el acceso por ID bajo carga concurrente.

