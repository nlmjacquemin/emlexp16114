# syntax=docker/dockerfile:1.4
FROM mambaorg/micromamba

# Build arguments
ARG IMAGE_VERSION=1.0.0
ARG FLYE_VERSION
ARG FLYE_SOURCE

# Inherit labels from base-labels
LABEL org.opencontainers.image.authors="Nicolas Jacquemin <nicolas.jacquemin.1@gmail.com>, EPFL-ENAC-EML <rizlan.bernier-latmani@epfl.ch>"
LABEL org.opencontainers.image.source="https://c4science.ch/source/emldockerfiles"
LABEL org.opencontainers.image.version=$IMAGE_VERSION
LABEL org.opencontainers.image.title="Flye Assembler"
LABEL org.opencontainers.image.description="Minimal Docker image with micromamba environment for Flye assembler (v$FLYE_VERSION)."
LABEL org.opencontainers.image.base.name="mambaorg/micromamba"
LABEL labs.eml.epfl.ch.package.flye.version="$FLYE_VERSION"
LABEL labs.eml.epfl.ch.package.flye.source="$FLYE_SOURCE"
LABEL labs.eml.epfl.ch.package.flye.description="Flye assembler for long-read sequencing."

# Install Flye using micromamba
RUN micromamba create -y -n flye -c bioconda -c conda-forge flye \
    && micromamba clean -a -y

# Set environment variables for micromamba
ENV PATH="/opt/conda/envs/flye/bin:$PATH"
