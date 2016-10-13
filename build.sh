#!/bin/bash

docker-compose build --pull
docker-compose run test
