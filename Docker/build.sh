#!/bin/bash
# $1 is the username
docker login
cd FlaskApp
docker build -t $1/flask-ic4302 .
docker push $1/flask-ic4302
cd ..