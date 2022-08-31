FROM jupyter/datascience-notebook:aarch64-julia-1.7.3
LABEL org.opencontainers.image.source="https://github.com/FAIRDataPipeline/RSECon22"
USER root

ARG FAIR_ENV

ENV FAIR_ENV=${FAIR_ENV} \
    GRANT_SUDO=yes \
    USER_HOME=/home/${NB_USER} \
    CONDA_R_LIB=/opt/conda/lib/R/library

RUN apt update && \
    apt install -y graphviz \
    default-jre \
    default-jdk \
    wget \
    unzip\
    gnuplot \
    build-essential \
    cmake \
    libjsoncpp-dev \
    curl \
    libcurl4-openssl-dev \
    libyaml-cpp-dev 

# Java
RUN wget https://services.gradle.org/distributions/gradle-7.5-bin.zip && \
    unzip gradle-*.zip
RUN cp -pr gradle-*/* /usr/local
RUN rm -r gradle-7.5 && \
    rm gradle-7.5-bin.zip && \
    mkdir temp

# Python Dependencies
WORKDIR ${USER_HOME}/temp
RUN wget https://raw.githubusercontent.com/FAIRDataPipeline/FAIR-CLI/develop/pyproject.toml && \
    wget https://raw.githubusercontent.com/FAIRDataPipeline/FAIR-CLI/develop/poetry.lock
RUN mamba install --quiet --yes 'poetry' && \
    mamba clean --all -f -y
RUN poetry config virtualenvs.create false \
    && poetry install --no-root --no-interaction --no-ansi

# Clone Repos and allow ambigous permissions
WORKDIR ${USER_HOME}
RUN git clone https://github.com/FAIRDataPipeline/cppSimpleModel.git && \
    git clone https://github.com/FAIRDataPipeline/DataPipeline.jl.git && \
    git clone https://github.com/FAIRDataPipeline/javaSimpleModel.git && \
    git clone https://github.com/FAIRDataPipeline/rSimpleModel.git && \
    git clone https://github.com/FAIRDataPipeline/rDataPipeline.git && \
    git config --global --add safe.directory ${USER_HOME}/cppSimpleModel && \
    git config --global --add safe.directory ${USER_HOME}/DataPipeline.jl && \
    git config --global --add safe.directory ${USER_HOME}/javaSimpleModel && \
    git config --global --add safe.directory ${USER_HOME}/rSimpleModel && \
    rm -r temp

# CPP Simple Model
WORKDIR ${USER_HOME}/cppSimpleModel
RUN cmake -Bbuild
RUN cmake --build build -j4

#Julia Simple Model
WORKDIR "${USER_HOME}/DataPipeline.jl"
RUN julia -e 'using Pkg; Pkg.instantiate()' && \
    julia --project=examples/fdp -e 'using Pkg; Pkg.instantiate()'

# Java Simple Model
WORKDIR "${USER_HOME}/javaSimpleModel"
RUN gradle build

# R Simple Model
WORKDIR ${USER_HOME}/rSimpleModel
RUN conda config --add channels pcgr && \
    conda config --add channels bioconda && \
    mamba install --quiet --yes \
    'poppler' \
    'librsvg' \
    'glib' \
    'bioconductor-rhdf5' \
    'r-rsvg' \
    'r-magick' \
    'r-pdftools' \
    && \
    mamba clean --all -f -y
RUN R -e 'cat(withr::with_libpaths(new="/opt/conda/lib/R/library", devtools::install_local() ) )'

WORKDIR ${USER_HOME}
COPY ./Notebooks .

# Permissiona
RUN fix-permissions "${JULIA_PKGDIR}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
