################################################################################
## NOTE
## 
## we could make even smaller docker images by setting up a multi-stage build
## but atm the image looks small enough to me and I don't feel like it's 
## necessary yet :)
## 
################################################################################

FROM python:3.11-alpine

ENV PS1="\[\e[0;33m\]|> excludarr <| \[\e[1;35m\]\W\[\e[0m\] \[\e[0m\]# "

RUN apk add --no-cache bash gcc libc-dev libffi-dev
RUN pip install --no-cache-dir poetry==1.8.3

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

# first setup the dependencies to not invalidate docker cache and speedup builds
COPY pyproject.toml poetry.lock ./
RUN touch README.md
RUN poetry install --without dev,types --no-root && rm -rf $POETRY_CACHE_DIR

# install excludarr
COPY excludarr ./excludarr
RUN poetry install --without dev,types

WORKDIR /

# used to mount the crontab
RUN mkdir -p /etc/excludarr

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
