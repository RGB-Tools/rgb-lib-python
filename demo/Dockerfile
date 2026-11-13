FROM debian:trixie-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        adduser libmagic1 python3-pip gcc python3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV USER="jupyter" PIP_BREAK_SYSTEM_PACKAGES=1
ENV PATH="/home/jupyter/.local/bin:$PATH"

RUN adduser --disabled-login --gecos "$USER user" $USER

WORKDIR /home/$USER
USER $USER

# requirement specifier for the rgb-lib package, override to test a local build
# (e.g. ./wheels/rgb_lib-<version>-py3-none-manylinux_2_34_x86_64.whl)
ARG RGB_LIB_SPEC="rgb-lib==0.3.0b7"

COPY --chown=$USER:$USER wheels/ ./wheels/

RUN python3 -m pip install --no-cache-dir --no-warn-script-location \
    jupyterlab matplotlib python-magic qrcode "$RGB_LIB_SPEC"

COPY --chown=$USER:$USER rgb-lib.ipynb regtest.py sample.png ./

CMD ["/home/jupyter/.local/bin/jupyter-lab", "--ip=0.0.0.0"]
