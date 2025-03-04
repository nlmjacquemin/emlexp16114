# syntax=docker/dockerfile:1

FROM mambaorg/micromamba

USER root

LABEL eml.labs.ch.epfl.image.authors="Nicolas Jacquemin <nicolas.jacquemin.1@gmail.com>, EPFL-ENAC-EML <rizlan.bernier-latmani@epfl.ch>"
LABEL eml.labs.ch.epfl.image.created="2024-07-22"

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

RUN micromamba create -n gtdbtk -c conda-forge -c bioconda gtdbtk=2.4.0

#RUN eval "$(micromamba shell hook --shell bash)" && micromamba activate gtdbtk && pip install numpy==1.23.1
