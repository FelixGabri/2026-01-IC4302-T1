
# IMPORTANTE
* Se deben seguir buenas prácticas de programación en el caso de que apliquen. Por ejemplo, documentación interna y externa, estándares de código, diagramas de arquitectura, diagramas de flujo, pruebas unitarias son algunas de las buenas prácticas que se esperan de un estudiante de Ingeniería en Computación.
* Hacerlo en GitHub




# Dudas
* Instrumentar una aplicación para exponer métricas mediante Prometheus. ¿Esto se refiere a?
* ¿Elasticsearch es para las BDs ó para algo de Grafana?



# DB (en cluster):

DBs DBbbean

## Objetivo:
Instalar y configurar motores de bases de datos SQL y NoSQL mediante Kubernetes.

## Stack:
* MariaDB con un mínimo de 3 instancias (1 primary y 2 replicas)
* MongoDB con 3 replicas
* PostgreSQL
* CouchDB
* Redis

# Aplicación intermediaria

## Objetivo:
Permitir la conexión http de Gatling con las BDs.

## Stack:
* Flask


# Pruebas (local):

Las pruebas e Gatling joden a las DBs, los datos se mandan a Prometheus

## Objetivo:
Implementar pruebas de carga sobre bases de datos SQL y NoSQL mediante el uso de la herramienta
Gatling.
## Stack:
* Gatling

Cada uno de los grupos deberá generar pruebas de carga con Gatling. Estas se realizarán sobre los
motores de bases de datos y deberán incluir los siguientes tipos de operaciones:
➔ Creación de registros/documentos.
➔ Borrado de registros/documentos.
➔ Actualización de registros/documentos.
➔ Búsquedas de registros/documentos.
Las pruebas deberán ejecutarse durante largos periodos de tiempo (al menos 30 minutos), con el fin de
generar gráficos de monitoreo que permitan observar el comportamiento de los diferentes motores de
bases de datos. Es importante observar, cuando sea posible, los siguientes parámetros (no todas las bases
de datos los exponen):
➔ Disco.
➔ Memoria.
➔ CPU.
➔ Red (Network).
➔ IOPS.
➔ Open Connections.
➔ Queries per second.
➔ Query response time.
➔ Thread Pools.
2026-01-IC4302-T1.md 2026-03-14
6 / 7
➔ File Descriptors.
La idea detrás de las pruebas de carga es medir el rendimiento de las bases de datos bajo una
configuración específica. Se recomienda utilizar el mismo conjunto de datos en diferentes motores para
poder realizar comparaciones. Es importante mencionar que Gatling se ejecutará fuera de Kubernetes.
Gatling es una herramienta que realiza pruebas de carga sobre endpoints HTTP. Sin embargo, no todas las
bases de datos SQL y NoSQL exponen una interfaz para interactuar mediante este protocolo. Por esta
razón, se deberá implementar una aplicación intermediaria, la cual se ilustra en la siguiente imagen.
La aplicación intermediaria deberá estar implementada en Python utilizando Flask, será administrada
mediante un Deployment de Kubernetes y estará expuesta a través de un servicio de tipo ClusterIP.
Además, esta aplicación deberá estar instrumentada para exponer métricas a Prometheus. Se puede utilizar
este ejemplo básico de instrumentación en el que únicamente se exponga el número de peticiones HTTP.


# Monitoreo (cluster):

Prometheus monitorea
Grafana muestra lo de prometeus

## Objetivo:
Instalar y configurar una solución de monitoreo y alertas utilizando Prometheus y Grafana.
## Stack:
* Prometheus
* Grafana
* Thanos (opcional)


Las configuraciones de Grafana se cargarán automáticamente mediante los Helm Charts que se instalarán.
Cada grupo deberá identificar cuáles son los dashboards más adecuados para visualizar los datos; estos
pueden encontrarse en https://grafana.com/grafana/dashboards/.
El profesor brindará un ejemplo de configuración que muestra cómo realizar esta tarea utilizando
Elasticsearch.
El siguiente es un ejemplo de cómo se verá un dashboard:



# Documentación
La documentación debe incluir al menos:
➔ Guía de instalación y uso de la tarea: se debe explicar en detalle cómo ejecutarla y cómo utilizarla.
➔ Configuración de las herramientas: haciendo énfasis en los valores utilizados para cada una.
➔ Pruebas de carga realizadas: se debe especificar el tipo de datos que se están almacenando (dataset), el
tipo de prueba (creación, borrado, actualización y búsqueda), los parámetros utilizados (configuración de
Gatling), los resultados (apoyados por la información de monitoreo y los gráficos obtenidos) y las
conclusiones de cada prueba. Se deben incluir al menos 5 pruebas por motor de base de datos.
➔ Conclusiones y recomendaciones de la tarea corta.






