# syntax=docker/dockerfile:1

FROM mambaorg/micromamba

USER root

LABEL eml.labs.ch.epfl.image.authors="Nicolas Jacquemin <nicolas.jacquemin.1@gmail.com>, EPFL-ENAC-EML <rizlan.bernier-latmani@epfl.ch>"
LABEL eml.labs.ch.epfl.image.created="2024-10-19"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	apt-utils \
	curl \
	git \
	nano \
	less \
	wget \
&& rm -rf /var/lib/apt/lists/*

# Installing software

ARG MAMBA_DOCKERFILE_ACTIVATE=1

RUN micromamba create -y -n checkm -c bioconda -c conda-forge checkm2 'python>=3.7, <3.9'

#RUN chmod 777 /opt/conda/envs/checkm2/lib/python3.8/site-packages/checkm2/version/diamond_path.json

