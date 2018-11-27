# docker-amber - Docker image for Amber development

[![Version](https://img.shields.io/github/tag/anamba/docker-amber.svg?maxAge=360)](https://github.com/anamba/docker-amber/releases/latest)
[![License](https://img.shields.io/github/license/anamba/docker-amber.svg)](https://github.com/anamba/docker-amber/blob/master/LICENSE)
[![Amber Framework](https://img.shields.io/badge/works_with-amber_framework-orange.svg)](https://amberframework.org)

Docker Hub: [anamba/crystal-amber-dev](https://hub.docker.com/r/anamba/crystal-amber-dev/)

Based on Phusion's excellent, developer-friendly [baseimage-docker](https://github.com/phusion/baseimage-docker) image (based on 18.04 LTS aka Bionic).

## Contents

Includes:

* Amber v0.11.1
* Crystal 0.27.0
* guardian

Working dir is `/home/app/myapp` (user is `app`). Default port is 3000.

## Versioning

* Docker tags track Amber versions.
* Crystal version is selected based on what is supported by the target Amber version.

## How to use

Example `docker-compose.yml`:
```yaml
version: '3'

services:
  web:
    image: anamba/crystal-amber-dev:0.11  # latest 0.11.x version
    ports:
      - '3000:3000'  # <-- change the first number to set your local port
    volumes:
      - ./:/home/app/myapp:delegated               # NOTE: :delegated is a Docker for Mac feature
      - node_modules:/home/app/myapp/node_modules  # keep node_modules off your local filesystem
    environment:
      AMBER_ENV: development
      PORT: 3000

  db:
    image: mariadb:10.3
    volumes:
      - db-data:/var/lib/mysql
    environment:
      MYSQL_ALLOW_EMPTY_PASSWORD: 1

volumes:
  db-data:
  node_modules:
```

From there, you can run `docker-compose up` to start the containers, then, in a separate terminal:
```bash
docker-compose exec -u app web amber watch   # run amber watch
docker-compose exec -u app web guardian      # run guardian
docker-compose exec -u app web crystal spec  # run crystal spec
docker-compose exec -u app web bash          # get a user shell
docker-compose exec web bash                 # get a root shell
```

You get the idea. You'll want to create aliases or simple shell scripts to save yourself some typing.

## Development

(notes for myself)

```
docker build -t anamba/crystal-amber-dev:latest .
docker tag anamba/crystal-amber-dev:latest anamba/crystal-amber-dev:0.11.1
docker tag anamba/crystal-amber-dev:latest anamba/crystal-amber-dev:0.11
docker push anamba/crystal-amber-dev
```
