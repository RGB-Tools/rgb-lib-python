FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends libmagic1 python3-pip gcc python3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV USER="jupyter" PIP_BREAK_SYSTEM_PACKAGES=1

RUN adduser --disabled-login --gecos "$USER user" $USER

WORKDIR /home/$USER
USER $USER

RUN python3 -m pip install --no-warn-script-location \
    jupyterlab matplotlib python-magic qrcode rgb-lib==0.3.0b1

COPY --chown=$USER:$USER rgb-lib.ipynb sample.png ./

CMD ["/home/jupyter/.local/bin/jupyter-lab", "--ip=0.0.0.0"]
