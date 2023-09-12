FROM rust:1.72-slim-bullseye

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential curl git gosu libssl-dev pkg-config python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN python3 -m pip install 'poetry~=1.4'

ENV APP_DIR="/opt/rgb-lib-python" USER="rgb"

RUN adduser --home ${APP_DIR} --shell /bin/bash --disabled-login \
        --gecos "${USER} user" ${USER}

WORKDIR $APP_DIR
ENV PY_SRC="src/rgb_lib"
ENV PY_SRC_INT="$PY_SRC/_rgb_lib"
RUN mkdir -p $PY_SRC_INT
COPY --chown=$USER:$USER generate.sh pyproject.toml README.md ./
COPY --chown=$USER:$USER $PY_SRC/__init__.py ./$PY_SRC/
COPY --chown=$USER:$USER $PY_SRC_INT/__init__.py ./$PY_SRC_INT/
COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
