#from flask import Flask
#import os
#app = Flask(__name__)

#@app.route("/")
#def hello_world():
#   DATA=os.getenv('PROMETHEUSENDPOINT')
#    return "<p>Hello, "+ DATA +"World!</p>"

# --- imports ---

## Framework principal para la API REST
from flask import Flask, jsonify, request

## Librerias para monitorear usando prometheus
from prometheus_client import  CONTENT_TYPE_LATEST
from prometheus_client import Counter, Histogram, generate_latest

## Clientes que se usaran para BD NoSQL
from pymongo import MongoClient
from elasticsearch import Elasticsearch
import redis
import couchdb

## Clientes que se usaran para BD SQL
import psycopg2
import mysql.connector

## Utilidades del sistema
import os
import uuid

## Para manejar el tiempo
from datetime import datetime

## Creara la aplicacion que se va a utilizar
app = Flask(__name__) 

# --- ---

# --- Metricas de prometheus ---

## Cuenta la cantidad de peticiones realizadas 
Peticiones_contador = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint', 'db']) 

## Histograma para poder medir el tiempo de respuesta en cada request
Peticiones_latencias = Histogram('http_request_duration_seconds', 'HTTP Request Latency', ['endpoint', 'db']) 

# --- ---


# --- Conexión a base de datos ---


# MongoDB
# Esta seccion se encarga de conectar mongo al cluster de kubernetes

#mongo_client = MongoClient(
#    "mongodb://mongouser:mongo123@databases-mongodb-headless:27017/ic4302?authSource=admin&directConnection=true"
#)

## Cliente principal para MONGODB
Cliente_mongo = MongoClient(
    "mongodb://mongouser:mongo123@databases-mongodb-0.databases-mongodb-headless:27017,databases-mongodb-1.databases-mongodb-headless:27017,databases-mongodb-2.databases-mongodb-headless:27017/ic4302?authSource=ic4302&replicaSet=rs0"
)

## BD que se utilizara para la APP
mongo_db = Cliente_mongo["ic4302"]


# PostgreSQL
## Se crea una conexion nueva a Postgres cada que se necesita

def conexion_POSTGRES():
    return psycopg2.connect(
        host="databases-postgresql",
        port=5432,
        database="postgres",
        user="postgres",
        password=os.environ.get("POSTGRES_PASSWORD", "")
    )

# MariaDB
## Se crea una conexion a MariaDB cada que se necesita

def conexion_MariaDB(): 
    return mysql.connector.connect(
        host="databases-mariadb-primary",
        port=3306,
        database="ic4302",
        user="mariadbuser",
        password="mariadb123"
    )

# Redis

#conexion_REDIS = redis.Redis(
#    host="databases-redis-master",
#    port=6379,
#    decode_responses=True
#)

## Redis utilizado para almacenar en la memoria
conexion_REDIS = redis.Redis(
    host="databases-redis-master",
    port=6379,
    password=os.environ.get("REDIS_PASSWORD", ""), #Redis usa una variable de entorno en kubernetes la cual es Redis_Password
    decode_responses=True #Redis devuelve strings
)

#ElasticSearch
## Se utiliza para busquedas y pruebas de rendimiento

conexion_ELASTIC = Elasticsearch(
    f"http://ic4302-es-http:9200",
    basic_auth=("elastic", os.environ.get("ES_PASSWORD", "")) #Otra variable de entorno
)


# CouchDB
## Cliente de Counch desplegado en kubernetes
def conexion_COUCHDB():
    #couch_client = couchdb.Server("http://couchdbuser:couchdb123@databases-svc-couchdb:5984")
    couch_user = os.environ.get("COUCH_USER", "admin")
    couch_pass = os.environ.get("COUCH_PASSWORD", "")
    couch_client = couchdb.Server(f"http://{couch_user}:{couch_pass}@databases-svc-couchdb:5984")

    try:
        return couch_client["ic4302"]
    except:
        return couch_client.create("ic4302")

# --- Termina la conexion a la base de datos ---

# --- Chequeo de funcionamiento ---

@app.route("/") #Crea un Healt check. Si responde el pod esta en funcionammiento.
def estado_servicio():
    return jsonify({"estado": "ok", 
    "mensaje": "LA API esta funcionando",
    "timestamp": str(datetime.now())})

@app.route("/metrics") #Prometheus scrape, para que grafana pueda tener las metricas recolectadas
def obtener_metricas():
   return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


# --- MongoDB endpoints ---
## Permite registrar usuarios en MongoDB, asi como metricas

@app.route("/mongo/users", methods=["POST"])
def crear_usuario_mongo(): 
    with Peticiones_latencias.labels(endpoint="/mongo/users", db="mongodb").time():
        Peticiones_contador.labels(method="POST", endpoint="/mongo/users", db="mongodb").inc()
        data = request.json or {}
        doc = {
            "userId": str(uuid.uuid4()),
            "name": data.get("name", "Test User"),
            "email": data.get("email", f"{uuid.uuid4()}@test.com"),
            "role": data.get("role", "user"),
            "createdAt": datetime.now()
        }
        result = mongo_db.users.insert_one(doc)
        return jsonify({"id": str(result.inserted_id)}), 201

## Permite leer los usuarios almacenados en MongoDB

@app.route("/mongo/users", methods=["GET"])
def leer_usuarios_mongo():
    with Peticiones_latencias.labels(endpoint="/mongo/users", db="mongodb").time():
        Peticiones_contador.labels(method="GET", endpoint="/mongo/users", db="mongodb").inc()
        users = list(mongo_db.users.find({}, {"_id": 0}).limit(10))
        return jsonify(users)

##  Permite actualizar la funcion de un usuario existente

@app.route("/mongo/users/<user_id>", methods=["PUT"])
def actualizar_usuario_mongo(user_id):
    with Peticiones_latencias.labels(endpoint="/mongo/users", db="mongodb").time():
        Peticiones_contador.labels(method="PUT", endpoint="/mongo/users", db="mongodb").inc()
        data = request.json or {}
        mongo_db.users.update_one({"userId": user_id}, {"$set": data})
        return jsonify({"updated": user_id})

## Permite eliminar un usario especifico usando su ID

@app.route("/mongo/users/<user_id>", methods=["DELETE"])
def eliminar_usuario_Mongo(user_id):
    with Peticiones_latencias.labels(endpoint="/mongo/users", db="mongodb").time():
        Peticiones_contador.labels(method="DELETE", endpoint="/mongo/users", db="mongodb").inc()
        mongo_db.users.delete_one({"userId": user_id})
        return jsonify({"deleted": user_id})


# --- POSTGRESQL ENDPOINTS ---
## Permite crear un usuario en Postgres

@app.route("/postgres/users", methods=["POST"])
def crear_usuario_Postgres():
    with Peticiones_latencias.labels(endpoint="/postgres/users", db="postgresql").time():
        Peticiones_contador.labels(method="POST", endpoint="/postgres/users", db="postgresql").inc()
        data = request.json or {}
        conn = conexion_POSTGRES()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO Users (name, second_name, age, country_ID, email) VALUES (%s, %s, %s, %s, %s) RETURNING ID",
            (data.get("name", "Test"), "Test", 25, 1, f"{str(uuid.uuid4())[:8]}@t.com")
        )
        user_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"id": user_id}), 201

## Permite leer un usuario en Postgres

@app.route("/postgres/users", methods=["GET"])
def leer_usuario_Postgres():
    with Peticiones_latencias.labels(endpoint="/postgres/users", db="postgresql").time():
        Peticiones_contador.labels(method="GET", endpoint="/postgres/users", db="postgresql").inc()
        conn = conexion_POSTGRES()
        cur = conn.cursor()
        cur.execute("SELECT ID, name, email FROM Users LIMIT 10")
        rows = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify([{"id": r[0], "name": r[1], "email": r[2]} for r in rows])

## Permite actualizar un usuario en Postgres

@app.route("/postgres/users/<user_id>", methods=["PUT"])
def actualizar_usuario_Postgres(user_id):
    with Peticiones_latencias.labels(endpoint="/postgres/users", db="postgresql").time():
        Peticiones_contador.labels(method="PUT", endpoint="/postgres/users", db="postgresql").inc()
        data = request.json or {}
        conn = conexion_POSTGRES()
        cur = conn.cursor()
        cur.execute("UPDATE Users SET name=%s WHERE ID=%s", (data.get("name", "Updated"), user_id))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"updated": user_id})

## Permite eliminar un usuario en Postgres utilizando el ID especifico

@app.route("/postgres/users/<user_id>", methods=["DELETE"])
def eliminar_usuario_Postgres(user_id):
    with Peticiones_latencias.labels(endpoint="/postgres/users", db="postgresql").time():
        Peticiones_contador.labels(method="DELETE", endpoint="/postgres/users", db="postgresql").inc()
        conn = conexion_POSTGRES()
        cur = conn.cursor()
        cur.execute("DELETE FROM Users WHERE ID=%s", (user_id,))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"deleted": user_id})


# --- MARIADB ENDPOINTS ---
## Permite crear un usuario en MariaDB

@app.route("/mariadb/users", methods=["POST"])
def crear_usuario_Maria():
    with Peticiones_latencias.labels(endpoint="/mariadb/users", db="mariadb").time():
        Peticiones_contador.labels(method="POST", endpoint="/mariadb/users", db="mariadb").inc()
        data = request.json or {}
        conn = conexion_MariaDB()
        cur = conn.cursor()
        cur.execute(
    "INSERT INTO Users (name, second_name, age, country_ID, email) VALUES (%s, %s, %s, %s, %s)",
    (data.get("name", "Test"), "Test", 25, 1, f"{str(uuid.uuid4())[:8]}@t.com")
)
        conn.commit()
        user_id = cur.lastrowid
        cur.close()
        conn.close()
        return jsonify({"id": user_id}), 201

## Permite leer un usuario en MariaDB

@app.route("/mariadb/users", methods=["GET"])
def leer_usuario_Maria():
    with Peticiones_latencias.labels(endpoint="/mariadb/users", db="mariadb").time():
        Peticiones_contador.labels(method="GET", endpoint="/mariadb/users", db="mariadb").inc()
        conn = conexion_MariaDB()
        cur = conn.cursor()
        cur.execute("SELECT ID, name, email FROM Users LIMIT 10")
        rows = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify([{"id": r[0], "name": r[1], "email": r[2]} for r in rows])

## Permite actualizar un usuario en MariaDB       

@app.route("/mariadb/users/<user_id>", methods=["PUT"])
def actualizar_usuario_Maria(user_id):
    with Peticiones_latencias.labels(endpoint="/mariadb/users", db="mariadb").time():
        Peticiones_contador.labels(method="PUT", endpoint="/mariadb/users", db="mariadb").inc()
        data = request.json or {}
        conn = conexion_MariaDB()
        cur = conn.cursor()
        cur.execute("UPDATE Users SET name=%s WHERE ID=%s", (data.get("name", "Updated"), user_id))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"updated": user_id})

## Permite eliminar un usuario en MariaDB usando el ID

@app.route("/mariadb/users/<user_id>", methods=["DELETE"])
def eliminar_usuario_Maria(user_id):
    with Peticiones_latencias.labels(endpoint="/mariadb/users", db="mariadb").time():
        Peticiones_contador.labels(method="DELETE", endpoint="/mariadb/users", db="mariadb").inc()
        conn = conexion_MariaDB()
        cur = conn.cursor()
        cur.execute("DELETE FROM Users WHERE ID=%s", (user_id,))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"deleted": user_id})


# --- REDIS ENDPOINTS ---
## Permite crear un usuario en Redis

@app.route("/redis/session", methods=["POST"])
def crear_usuario_Redis():
    with Peticiones_latencias.labels(endpoint="/redis/session", db="redis").time():
        Peticiones_contador.labels(method="POST", endpoint="/redis/session", db="redis").inc()
        data = request.json or {}
        session_id = str(uuid.uuid4())
        conexion_REDIS.setex(session_id, 3600, str(data))
        return jsonify({"session_id": session_id}), 201

## Permite leer un usuario en Redis

@app.route("/redis/session/<session_id>", methods=["GET"])
def leer_usuario_Redis(session_id):
    with Peticiones_latencias.labels(endpoint="/redis/session", db="redis").time():
        Peticiones_contador.labels(method="GET", endpoint="/redis/session", db="redis").inc()
        value = conexion_REDIS.get(session_id)
        return jsonify({"session_id": session_id, "value": value})

## Permite actualizar un usuario en Redis

@app.route("/redis/session/<session_id>", methods=["PUT"])
def actualizar_usuario_Redis(session_id):
    with Peticiones_latencias.labels(endpoint="/redis/session", db="redis").time():
        Peticiones_contador.labels(method="PUT", endpoint="/redis/session", db="redis").inc()
        data = request.json or {}
        conexion_REDIS.setex(session_id, 3600, str(data))
        return jsonify({"updated": session_id})

## Permite eliminar un usuario en Redis usando el ID

@app.route("/redis/session/<session_id>", methods=["DELETE"])
def eliminar_usuario_Redis(session_id):
    with Peticiones_latencias.labels(endpoint="/redis/session", db="redis").time():
        Peticiones_contador.labels(method="DELETE", endpoint="/redis/session", db="redis").inc()
        conexion_REDIS.delete(session_id)
        return jsonify({"deleted": session_id})


# --- COUCHDB ENDPOINTS ---
## Permite crear un usuario en Couch

@app.route("/couch/users", methods=["POST"])
def crear_usuario_Couch():
    couch_db = conexion_COUCHDB()
    with Peticiones_latencias.labels(endpoint="/couch/users", db="couchdb").time():
        Peticiones_contador.labels(method="POST", endpoint="/couch/users", db="couchdb").inc()
        data = request.json or {}
        doc = {
            "_id": str(uuid.uuid4()),
            "name": data.get("name", "Test User"),
            "email": f"{uuid.uuid4()}@test.com",
            "createdAt": str(datetime.now())
        }
        couch_db.save(doc)
        return jsonify({"id": doc["_id"]}), 201

## Permite leer un usuario en Couch

@app.route("/couch/users", methods=["GET"])
def leer_usuario_Couch():
    couch_db = conexion_COUCHDB()
    with Peticiones_latencias.labels(endpoint="/couch/users", db="couchdb").time():
        Peticiones_contador.labels(method="GET", endpoint="/couch/users", db="couchdb").inc()
        docs = [couch_db[doc_id] for doc_id in list(couch_db)[:10]]
        return jsonify([dict(d) for d in docs])

## Permite actualizar un usuario en Couch

@app.route("/couch/users/<doc_id>", methods=["PUT"])
def actualizar_usuario_Couch(doc_id):
    couch_db = conexion_COUCHDB()
    with Peticiones_latencias.labels(endpoint="/couch/users", db="couchdb").time():
        Peticiones_contador.labels(method="PUT", endpoint="/couch/users", db="couchdb").inc()
        data = request.json or {}
        doc = couch_db[doc_id]
        doc.update(data)
        couch_db.save(doc)
        return jsonify({"updated": doc_id})

## Permite eliminar un usuario en Couch usando el ID

@app.route("/couch/users/<doc_id>", methods=["DELETE"])
def eliminar_usuario_Couch(doc_id):
    couch_db = conexion_COUCHDB()
    with Peticiones_latencias.labels(endpoint="/couch/users", db="couchdb").time():
        Peticiones_contador.labels(method="DELETE", endpoint="/couch/users", db="couchdb").inc()
        doc = couch_db[doc_id]
        couch_db.delete(doc)
        return jsonify({"deleted": doc_id})




# --- ELASTICSEARCH ---
## Permite crear un usuario en ES

@app.route("/elastic/users", methods=["POST"])
def crear_usuario_ES():
    with Peticiones_latencias.labels(endpoint="/elastic/users", db="elasticsearch").time():
        Peticiones_contador.labels(method="POST", endpoint="/elastic/users", db="elasticsearch").inc()
        data = request.json or {}
        doc = {
            "name": data.get("name", "Test User"),
            "email": f"{uuid.uuid4()}@test.com",
            "age": data.get("age", 25),
            "city": data.get("city", "Test City"),
            "createdAt": str(datetime.now())
        }
        result = conexion_ELASTIC.index(index="users", document=doc)
        return jsonify({"id": result["_id"]}), 201

## Permite leer un usuario en ES

@app.route("/elastic/users", methods=["GET"])
def leer_usuario_ES():
    with Peticiones_latencias.labels(endpoint="/elastic/users", db="elasticsearch").time():
        Peticiones_contador.labels(method="GET", endpoint="/elastic/users", db="elasticsearch").inc()
        result = conexion_ELASTIC.search(index="users", query={"match_all": {}}, size=10)
        users = [hit["_source"] for hit in result["hits"]["hits"]]
        return jsonify(users)

## Permite actualizar un usuario en ES

@app.route("/elastic/users/<doc_id>", methods=["PUT"])
def actualizar_usuario_ES(doc_id):
    with Peticiones_latencias.labels(endpoint="/elastic/users", db="elasticsearch").time():
        Peticiones_contador.labels(method="PUT", endpoint="/elastic/users", db="elasticsearch").inc()
        data = request.json or {}
        conexion_ELASTIC.update(index="users", id=doc_id, doc=data)
        return jsonify({"updated": doc_id})

## Permite eliminar un usuario en ES con el ID

@app.route("/elastic/users/<doc_id>", methods=["DELETE"])
def eliminar_usuario_ES(doc_id):
    with Peticiones_latencias.labels(endpoint="/elastic/users", db="elasticsearch").time():
        Peticiones_contador.labels(method="DELETE", endpoint="/elastic/users", db="elasticsearch").inc()
        conexion_ELASTIC.delete(index="users", id=doc_id)
        return jsonify({"deleted": doc_id})








# ============================================
# MAIN
# ============================================
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)


