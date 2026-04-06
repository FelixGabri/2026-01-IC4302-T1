---

---
----------------------------------------
- IC4302 - Bases de Datos II
- Gerardo Nereo Campos Araya
- Integrantes:
     + Andrés Martínez Fumero
     + Fabian Flores Alvarado
     + Felix Morales Cerdas
     + Oscar Bezara Perez
     + Javier Rodríguez Menjívar
-----------------------------
# Instrucciones de Ejecución

## Requisitos Previos

### Herramientas necesarias

| Herramienta                 | Uso en el proyecto                                                    |
| --------------------------- | --------------------------------------------------------------------- |
| Docker + Docker Hub Account | Construir y publicar las imágenes de los contenedores                 |
| kubectl                     | Interactuar con el clúster de Kubernetes                              |
| Helm 3                      | Desplegar todos los servicios del proyecto                            |
| Kubernetes local            | Ejecutar los servicios (Docker Desktop en Windows, Minikube en Linux) |
| Git Bash                    | Correr los scripts .sh en Windows                                     |
| Java 21 (JDK)               | Correr las pruebas de gatilng                                         |
| Maven (mvnw)                | Utilizado para gatling                                                |

##### Bases de datos

* ElasticSearch
* MariaDB
* Posgres
* Couch
* Redis
* MongoDB

--------------------------
## Limpieza total

En caso de que se tengan tecnologías en uso y quieran borrarlas siga los siguientes pasos:

##### Desinstalar todos los releases de Helm
``` Bash
helm uninstall app -n default
helm uninstall grafana-config -n monitoring
helm uninstall monitoring-stack -n monitoring
helm uninstall databases -n default
helm uninstall bootstrap -n default
```
#### Eliminar los namespaces creados
``` Bash
kubectl delete namespace monitoring
kubectl delete namespace elastic-system
``` 
#### Eliminar todos los PersistentVolumeClaims
``` Bash
kubectl delete pvc --all
kubectl delete pvc --all -n monitoring
```
#### Verificar que el clúster este limpio
``` Bash
kubectl get pods --all-namespaces
```

--------------------

## Pasos de instalación

### Paso 1 - Instalar Docker

- Descarga Docker Desktop desde [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
- Instálalo con las opciones por defecto
- Una vez instalado, abre Docker Desktop
- En **Settings → Kubernetes** activa la casilla **"Enable Kubernetes"**
- Click en **Apply & Restart**
- Espera hasta que ambos íconos (Docker y Kubernetes) estén en **verde**

Para verificar que funciona:
``` Bash
kubectl version --client
```
### Paso 2 - Instalar Helm 3

Con GitBash corre:

``` Bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

O mediante la pagina oficial https://helm.sh/docs/intro/install/

Para verificar la instalacion:
``` Bash
helm version
```

Una vez instalado se descargaran los repositorios necesarios
``` Bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 
helm repo add couchdb https://apache.github.io/couchdb-helm 
helm repo update
```
### Paso 3 - Instalar Java21 (JDK)

1. Descarga JDK 21 desde https://adoptium.net/
2. Selecciona: 
    * Versión: 21 (LTS)
    * Os: Windows
    * Architecture: x64
    * Package: JDK
3. Se descarga el .msi y se instala con todas las opciones por defecto

Para configurarlo como variable de entorno se ejecuta **PowerShell** como administrador y se ejecuta:

``` Bash
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Eclipse Adoptium\jdk-21", "Machine")
```

Y se verifica en una nueva terminal:

``` Bash
java --version
```
### Paso 4 - Instalar los charts del proyecto


Abre **GitBash** en la carpeta del proyecto y corre el siguiente script:
``` GitBash
cd TC1/charts
bash install.sh
```

Este script instala todos los servicios en el siguiente orden:

| Paso | Chart            | Descripción                                                                            | Espera      |
| ---- | ---------------- | -------------------------------------------------------------------------------------- | ----------- |
| 1    | bootstrap        | Instala el operador ECK para ElasticSearch                                             | 20 segundos |
| 2    | databases        | Instala MariaDB, Redis, MongoDB, CouchDB, PostgreSQL, Elasticsearch, Kibana, Memcached | 60 segundos |
| 3    | monitoring-stack | Instala Prometheus y Grafana                                                           | -           |
| 4    | grafana-config   | Configura los dashboards de grafana                                                    | -           |

Si Grafana falla al instalar
``` Bash
helm uninstall grafana-config 
helm upgrade --install grafana-config grafana-config -n monitoring
```
### Paso 5 - Construir e instalar las imágenes de Docker

En la carpeta principal del proyecto use el siguiente script:

``` Bash
cd Tc1/Docker
bash build.sh usuario-de-docker
```

### Paso 6 - Construir y desplegar la aplicación Flask

Edite el archivo `TC1/Charts/app/values.yaml` y actualice la imagen con el usuario de Docker:

``` yaml
image: usuario-de-docker/flask-ic4302:latest
```

Luego instala la app:

``` bash
cd TC1/charts
helm upgrade --install app app
```

### Paso 7 - Verificar que todo este funcionando

``` bash
kubectl get pods
kubectl get pods -n monitoring
```
Todos los pods deben estar en estado `Running`. Si alguno está en `CrashLoopBackOff` o `Pending`revisa los logs:
``` bash
kubectl logs <nombre-del-pod>
```
### Paso 8 - Acceder a Grafana

Abre un port forward:
``` bash
kubectl port-forward svc/monitoring-stack-grafana-grafana-service 3000:3000 -n monitoring
```

Abre http://localhost:3000/ en el navegador.

Para obtener las credenciales para entrar a grafana use el siguiente script:

``` bash
# Usuario
kubectl get secret monitoring-stack-grafana-grafana-admin-credentials -n monitoring \ -o jsonpath="{.data.GF_SECURITY_ADMIN_USER}" | base64 --decode

# Contraseña
kubectl get secret monitoring-stack-grafana-grafana-admin-credentials -n monitoring \ -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 --decode
```
### Paso 9 - Correr pruebas con gatling

Ejecuta una prueba de 30 minutos para Mongo:
``` bash
cd TC1/gatling 
mvnw.cmd gatling:test -Dgatling.simulationClass=example.MongoSimulation
```

##### Verificación rápida del cluster

``` bash
# Ver todos los pods
kubectl get pods --all-namespaces

# Ver los deployments
kubectl get deployments

# Ver los servicios
kubectl get svc

# Ver logs de un pod específico
kubectl logs <nombre-del-pod>

# Describir un pod con problemas
kubectl describe pod <nombre-del-pod>
```

------------

# Recomendaciones

- Usar curl o Postman para verificar que los endpoints de la app Flask responden antes de correr Gatling
- Correr `kubectl get pods` después de cada `helm install` para confirmar que los pods están en `Running` antes de continuar
- Usar el mismo dataset en todas las bases de datos para que las comparaciones de rendimiento sean justas
- Si Grafana falla al instalar, desinstalarlo y reinstalarlo con `helm upgrade --install` antes de investigar más
- Activar los ServiceMonitors de Prometheus en el `values.yaml` de cada base de datos desde el inicio
- Usar dashboards existentes de [https://grafana.com/grafana/dashboards](https://grafana.com/grafana/dashboards) para las bases de datos en vez de crearlos desde cero
- Correr las pruebas de Gatling de a una a la vez para no saturar los recursos del clúster
- Hacer commits frecuentes al repositorio, especialmente antes de hacer cambios grandes en los Helm Charts
- Agregar `initContainers` en la app Flask para que espere a que las bases de datos estén listas antes de arrancar
- Verificar la versión de Java con `java --version` antes de correr Gatling — debe ser la 21

----------------
# Conclusiones
- Se logró observar diferencias importantes entre bases de datos relacionales y NoSQL, especialmente en términos de estructura de datos, velocidad de inserción y flexibilidad de consultas.
- Las pruebas realizadas con Gatling demostraron la importancia del testing de rendimiento para identificar el comportamiento real de los sistemas bajo condiciones de carga.
- El uso de Prometheus evidenció la importancia del monitoreo continuo en aplicaciones distribuidas para detectar problemas de rendimiento y consumo de recursos.
- Grafana permitió visualizar de forma clara las métricas recolectadas, facilitando el análisis del comportamiento del sistema durante las pruebas realizadas.
- Helm simplificó significativamente el despliegue del sistema, demostrando el valor de la automatización en la configuración de infraestructuras complejas.
- Se reforzaron habilidades prácticas en resolución de errores, especialmente relacionados con configuración de contenedores, networking en Kubernetes y dependencias entre servicios.
- El proyecto permitió comprender mejor la arquitectura de microservicios y la importancia de separar responsabilidades entre los diferentes componentes del sistema.
- Como aprendizaje general, el proyecto permitió adquirir experiencia práctica en tecnologías modernas utilizadas en entornos reales de desarrollo y DevOps, fortaleciendo conocimientos en integración de sistemas, Observabilidad y despliegue de aplicaciones distribuidas.
- La integración de múltiples bases de datos dentro de un mismo sistema permitió entender los retos asociados a la interoperabilidad entre diferentes tecnologías y la importancia de estandarizar los métodos de acceso a datos desde la aplicación.
- El uso de herramientas de Observabilidad y pruebas permitió comprobar que el rendimiento de un sistema no depende únicamente del código de la aplicación, sino también de la infraestructura, configuración de recursos y comunicación entre servicios.

----------------
# Descripción de los componentes

## Docker

##### Uso en el proyecto  
Docker se utilizo para construir imágenes de los microservicios del sistema, lo que permitió su despliegue dentro del clúster de kubernetes.
Los servicios incluyen:

* Aplicación Flask
* Servicios de bases de datos
* Herramientas de monitoreo
* Microservicios de procesamiento
Las imágenes se construyen mediante: ``` Docker/Build.sh```
##### Componentes utilizados  
  Dentro del proyecto se uso:
  - Dockerfile para construir imágenes
  - Docker hub para almacenar imágenes
  - Scripts te automatización de build

##### Ventajas en el sistema
Docker permitio:
- Portabilidad
- Despliegue reproducible
- Separación de servicios
- Facilidad de debugging
- Integración sencilla con Kubernetes

## Kubernetes

##### Uso en el proyecto  
Kubernetes se utilizó como la infraestructura principal del sistema, encargándose de:
- Desplegar los microservicios
- Administrar las bases de datos
- Manejar networking interno
- Gestionar almacenamiento persistente
- Ejecutar monitoreo del sistema
Todos los servicios se despliegan mediante Helm Charts.

##### Componentes utilizados  
El proyecto utiliza:
- Pods
- Services
- Deployments
- Namespaces
- Persistent Volumes
- ConfigMaps
- Secrets

Namespaces utilizados:
- default
- monitoring
- elastic-system

##### Ejemplo dentro del proyecto  
Para verificar servicios:
``` Bash
kubectl get pods
kubectl get svc
kubectl get deployments
```

Para revisar logs:
``` Bash
kubectl logs nombre-del-pod
```
##### Ventajas en el sistema
Kubernetes permitió:
- Orquestación automática
- Reinicio automático de servicios fallidos
- Escalabilidad
- Balanceo de carga
- Gestión centralizada

## Helm

##### Descripción  
Helm es un gestor de paquetes para Kubernetes que permite definir, instalar y actualizar aplicaciones mediante archivos llamados Charts.

Facilita la automatización del despliegue y configuración de múltiples servicios complejos.

##### Uso en el proyecto  
Helm se utilizó para desplegar:
- Bases de datos
- Sistema de monitoreo
- Aplicación Flask
- Dashboards de Grafana

Esto permitió instalar todo el sistema con pocos comandos.
Charts utilizados:
``` 
charts/bootstrap
charts/databases
charts/monitoring-stack
charts/grafana-config
charts/app
```
##### Componentes utilizados  
Archivos importantes:
```
Chart.yaml → define el chart  
values.yaml → configuración  
templates → manifiestos Kubernetes
```

##### Ejemplo dentro del proyecto  
Instalación completa:
``` bash
cd TC1/charts
bash install.sh
```

Instalar aplicación:
``` bash
helm upgrade --install app app
```
##### Ventajas en el sistema
Helm permitió:
- Automatizar despliegues
- Versionar configuraciones
- Reutilizar configuraciones
- Reducir errores manuales
- Simplificar mantenimiento
## Flask

##### Descripción  
Flask es un framework web ligero en Python utilizado para construir APIs REST.
##### Uso en el proyecto  
Flask funciona como la API principal del sistema permitiendo:
- Consultas a bases de datos
- Inserción de datos
- Pruebas de rendimiento
- Integración con Gatling

La aplicación corre como un microservicio dentro de Kubernetes.

##### Componentes utilizados  
Dentro del proyecto:

- Flask
- PyMySQL
- psycopg2
- redis
- pymongo
- elasticsearch
- couchdb

##### Ejemplo dentro del proyecto  
Estructura básica:
``` Python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "API Running"
```
  
Conexión a base de datos:
``` Python
def Leer_usuario_BD():  
    connection = mariadb.connect(  
    host="mariadb",  
    user="root",  
    password="root"  
)
```

##### Ventajas en el sistema
Flask permitió:
- API simple
- Fácil integración con Python
- Conexión sencilla a múltiples DB
- Facilidad para testing
- Bajo consumo de recursos

## MariaDB

##### Uso en el proyecto  
MariaDB se utilizó para almacenar información estructurada de usuarios y realizar pruebas de inserción y consulta para comparar rendimiento contra otras bases de datos.
Se conecta desde la aplicación Flask mediante el conector de Python.
##### Componentes utilizados  
Dentro del proyecto:
- MariaDB container
- Python connector
- Kubernetes Service
- Persistent Volume

Librería utilizada:
``` Python
PyMySQL / mariadb connector
```

##### Ejemplo dentro del proyecto  
Ejemplo de conexión:
``` Python
def Leer_usuario_BD():  
    connection = mariadb.connect(  
        host="mariadb",  
        port=3306,  
        user="root",  
        password="root",  
        database="usuarios"  
    )  
    cursor = connection.cursor()  
    cursor.execute("SELECT * FROM usuarios")  
return cursor.fetchall()
```
##### Ventajas en el sistema
MariaDB permitió
- Comparación contra NoSQL
- Evaluación SQL tradicional
- Consultas estructuradas
- Alta compatibilidad
- Buen rendimiento en lecturas
## Redis

##### Uso en el proyecto  
PostgreSQL se utilizó como alternativa relacional para comparar rendimiento contra MariaDB.
Se utilizó para pruebas de:
- Inserts
- Selects
- Stress testing
##### Componentes utilizados  
Dentro del sistema:
- PostgreSQL container
- psycopg2 driver
- Kubernetes deployment
Librería utilizada:
``` Python
psycopg2
```

##### Ejemplo dentro del proyecto  
Ejemplo de conexión:
``` Python
import psycopg2

def leer_postgres():
    connection = psycopg2.connect(
        host="postgres",
        database="usuarios",
        user="postgres",
        password="postgres"
    )
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM usuarios")
    return cursor.fetchall()
```

##### Ventajas en el sistema
PostgreSQL permitió:
- Comparación entre motores SQL
- Pruebas de consistencia ACID
- Evaluación bajo carga
- Manejo robusto de transacciones

## MongoDB

##### Uso en el proyecto
MongoDB se utilizó para almacenar los mismos datos utilizados en las bases relacionales pero en formato documento para comparar:
- Velocidad de inserción
- Tiempo de consulta
- Escalabilidad

##### Componentes utilizados  
Dentro del proyecto:
- MongoDB container
- pymongo driver
- Kubernetes Service

Librería utilizada:
``` Python
pymongo
```

##### Ejemplo dentro del proyecto  
Ejemplo de conexión:
``` Python
from pymongo import MongoClient

def leer_mongo():
    client = MongoClient("mongodb://mongo:27017")
    db = client["usuarios"]
    collection = db["usuarios"]
    return list(collection.find())
```

##### Ventajas en el sistema
MongoDB permitió:
- Evaluar NoSQL vs SQL
- Flexibilidad de estructura
- Buen rendimiento en inserts
- Escalabilidad horizontal

## Redis

##### Uso en el proyecto  
Redis se utilizó para pruebas de almacenamiento rápido y comparación contra bases persistentes.
Se evaluó:
- Velocidad de lectura
- Velocidad de escritura
- Tiempo de respuesta

##### Componentes utilizados  
Dentro del proyecto:
- Redis container
- redis-py
- Kubernetes Service

Librería:
``` Python
redis
```

##### Ejemplo dentro del proyecto  
Ejemplo de conexión:
``` Python
import redis

def leer_redis():

    r = redis.Redis(
        host='redis',
        port=6379,
        decode_responses=True
    )
    return r.get("usuario")
```

##### Ventajas en el sistema
Redis permitió:
- Evaluar almacenamiento en memoria
- Pruebas de baja latencia
- Comparación contra almacenamiento persistente
- Evaluación de caching

## CouchDB

##### Uso en el proyecto  
Se utilizó CouchDB para evaluar otro enfoque NoSQL basado en REST APIs.

Se comparó contra MongoDB en:
- Inserts
- Queries
- Response time

##### Componentes utilizados  
Dentro del proyecto:
- CouchDB container
- Python couchdb library
- Kubernetes deployment
Librería:
``` Python
couchdb
```

##### Ejemplo dentro del proyecto  
Ejemplo de conexión:
``` Python
import couchdb

def leer_couch():

    couch = couchdb.Server("http://admin:admin@couchdb:5984")

    db = couch["usuarios"]

    return [doc for doc in db]
```
##### Ventajas en el sistema
CouchDB permitió:
- Comparación entre NoSQL
- Evaluar acceso REST
- Facilidad de replicación
- Manejo JSON nativo

## ElasticSearch

##### Uso en el proyecto  
ElasticSearch se utilizó para:
- Evaluar búsquedas rápidas
- Comparar inserts contra otras DB
- Pruebas de rendimiento

##### Componentes utilizados  
Dentro del proyecto:
- Elasticsearch cluster
- Python elasticsearch client
- Kubernetes operator (ECK)

Librería:
``` Python
elasticsearch
```

##### Ejemplo dentro del proyecto  
Ejemplo de conexión:
``` Python
from elasticsearch import Elasticsearch

def leer_elastic():

    es = Elasticsearch("http://elasticsearch:9200")

    result = es.search(
        index="usuarios",
        query={"match_all": {}}
    )

    return result
```
##### Ventajas en el sistema
Elasticsearch permitió:
- Evaluar motor de búsqueda
- Pruebas de indexing
- Alta velocidad en queries

## Prometheus

##### Descripción  
Prometheus es un sistema de monitoreo y recolección de métricas diseñado para entornos distribuidos y microservicios. Funciona recolectando métricas mediante endpoints HTTP y almacenándolas como series de tiempo.
Es ampliamente utilizado junto con Kubernetes debido a su integración nativa.

##### Uso en el proyecto  
Prometheus se utilizó para monitorear el comportamiento del sistema durante las pruebas de rendimiento, permitiendo observar:
- Uso de CPU
- Uso de memoria
- Requests por segundo
- Estado de pods
- Métricas de bases de datos
- Estado de microservicios
Se instaló mediante Helm como parte del monitoring stack.

##### Componentes utilizados  
Dentro del proyecto se utilizó:
- Prometheus Server
- Prometheus Operator
- ServiceMonitors
- Exporters
- Kubernetes metrics

Chart utilizado:
```
monitoring-stack
```
Repositorio Helm:
``` bash 
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```
##### Ejemplo dentro del proyecto  
Instalación del monitoring stack:
``` bash
helm upgrade --install monitoring-stack prometheus-community/kube-prometheus-stack -n monitoring
```
Veridicar pods:
``` bash 
kubectl get pods -n monitoring
```

##### Integración con Kubernetes
Prometheus monitorea automáticamente:
- Pods
- Nodes
- Services
- Deployments

Esto permite detectar:
- Fallos
- Cuellos de botella
- Problemas de recursos
##### Ventajas en el sistema
Prometheus permitió:
- Monitoreo en tiempo real
- Recolección automática de métricas
- Integración con Kubernetes
- Base para visualización en Grafana
- Análisis de rendimiento durante Gatling

## Grafana

##### Descripción  
Grafana es una plataforma de visualización de datos que permite crear dashboards interactivos a partir de múltiples fuentes de datos como Prometheus.
Se utiliza para transformar métricas en gráficos comprensibles.

##### Uso en el proyecto  
Grafana se utilizó para visualizar las métricas recolectadas por Prometheus mediante dashboards que permiten analizar el comportamiento del sistema durante las pruebas.

Se utilizó para visualizar:
- CPU usage
- Memory usage
- Network traffic
- Database metrics
- Kubernetes health
- Performance testing metrics

##### Componentes utilizados  
Dentro del proyecto:
- Grafana Server
- Dashboards JSON
- Prometheus datasource
- Kubernetes dashboards

Chart utilizado:
```
grafana-config
```

##### Ejemplo dentro del proyecto  
Acceso mediante port forward:
``` bash 
kubectl port-forward svc/monitoring-stack-grafana-grafana-service 3000:3000 -n monitoring
```
Acceso:
```
http://localhost:3000
```
Obtención de credenciales:
``` bash
kubectl get secret monitoring-stack-grafana-grafana-admin-credentials -n monitoring \ -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 --decode
```

##### Dashboards utilizados

El proyecto utiliza dashboards para visualizar:
- Kubernetes cluster metrics
- Database performance
- Resource consumption
- Application metrics

Los dashboards fueron configurados mediante archivos JSON dentro del chart:
```
grafana-config/dashboards
```

###### Integración con Prometheus

Grafana utiliza Prometheus como datasource principal para obtener métricas mediante consultas PromQL.
Flujo:
```
Kubernetes → Prometheus → Grafana → Dashboards
```

##### Ventajas en el sistema
Grafana permitió:
- Visualización clara de métricas
- Dashboards en tiempo real
- Análisis de performance
- Identificación de problemas
- Comparación de bases de datos


## Gatling

##### Uso en el proyecto  
Gatling se utilizó para ejecutar pruebas de rendimiento sobre los endpoints de la aplicación Flask y medir el comportamiento de las diferentes bases de datos bajo carga.

Se realizaron pruebas de:
- Inserts masivos
- Consultas concurrentes
- Pruebas de estrés
- Comparación de tiempos de respuesta

##### Componentes utilizados  
Dentro del proyecto:
- Gatling simulations
- Maven wrapper
- Java JDK 21
- Performance reports

Herramientas:
```
Gatling
Maven
Java 21
```

##### Ejemplo dentro del proyecto  

``` Bash
cd TC1/gatling

mvnw.cmd gatling:test \
-Dgatling.simulationClass=example.MongoSimulation
```

###### Métricas evaluadas

Gatling permitió medir:
- Response time
- Throughput
- Error rate
- Requests per second
- Latencia promedio
##### Ventajas en el sistema

Gatling permitió:
- Comparar rendimiento entre DB
- Detectar cuellos de botella
- Medir estabilidad del sistema
- Evaluar escalabilidad
- Generar reportes detallados

---------
