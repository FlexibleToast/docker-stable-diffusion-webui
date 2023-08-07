FROM nvidia/cuda:12.2.0-base-ubuntu20.04

COPY entrypoint.sh /app/entrypoint.sh

ARG DEBIAN_FRONTEND=noninteractive
ARG PUID=1000
ARG PGID=1000
ENV PUID=${PUID}
ENV PGID=${PGID}

RUN apt update && \
    apt install -y python3 python3-pip python3-venv git wget libgl1-mesa-dev libglib2.0-0 libsm6 libxrender1 libxext6 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -g $PGID sdgroup && \
    useradd -m -s /bin/bash -u $PUID -g $PGID --home /app sduser && \
    chown -R sduser:sdgroup /app && \
    chmod +x /app/entrypoint.sh

USER sduser
WORKDIR /app

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui stable-diffusion-webui

VOLUME /app/stable-diffusion-webui/extensions
VOLUME /app/stable-diffusion-webui/models
VOLUME /app/stable-diffusion-webui/outputs
VOLUME /app/stable-diffusion-webui/localizations

EXPOSE 8080

ENV PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.9,max_split_size_mb:512

ENTRYPOINT ["/app/entrypoint.sh", "--update-check", "--xformers", "--listen", "--port", "8080"]
CMD ["--medvram"]
