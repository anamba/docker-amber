# docker-amber - Docker image for Amber development

Based on Phusion's [baseimage-docker](https://github.com/phusion/baseimage-docker).

Includes:

* Crystal 0.27.0
* Amber v0.11.1
* guardian

Working dir is `/home/app/myapp` (user is `app`). Default port is 3000.

To build:

```
docker build -t anamba/crystal-amber-dev:latest .
docker tag anamba/crystal-amber-dev:latest anamba/crystal-amber-dev:0.1.0
docker push anamba/crystal-amber-dev
```
