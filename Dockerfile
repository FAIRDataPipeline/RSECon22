FROM jupyter/datascience-notebook:julia-1.7.3
LABEL org.opencontainers.image.source="https://github.com/FAIRDataPipeline/RSECon22"
USER root

ARG FAIR_ENV

ENV FAIR_ENV=${FAIR_ENV} \
    GRANT_SUDO=yes \
    HOME=/home/jovyan

RUN apt update
RUN apt-get install -y graphviz

# Java
RUN apt install -y default-jre
RUN apt install -y default-jdk
RUN apt install -y wget unzip
RUN wget https://services.gradle.org/distributions/gradle-7.5-bin.zip
RUN unzip gradle-*.zip
RUN cp -pr gradle-*/* /usr/local
RUN rm -r gradle-7.5
RUN rm gradle-7.5-bin.zip

# Python Dependencies
RUN mkdir temp
WORKDIR ${HOME}/temp
#RUN wget https://raw.githubusercontent.com/FAIRDataPipeline/data-registry/main/local-requirements.txt
RUN wget https://raw.githubusercontent.com/FAIRDataPipeline/FAIR-CLI/develop/pyproject.toml
#RUN conda install -y --file local-requirements.txt
RUN conda install -y -c conda-forge poetry
RUN poetry config virtualenvs.create false \
    && poetry install --no-root --no-interaction --no-ansi
RUN rm pyproject.toml
RUN rm poetry.lock
RUN wget https://raw.githubusercontent.com/FAIRDataPipeline/data-registry/main/pyproject.toml
RUN poetry install --no-root --no-interaction --no-ansi
WORKDIR ${HOME}
RUN rm -r temp

# CPP Simple Model

WORKDIR ${HOME}
RUN apt install -y gnuplot
RUN apt install -y build-essential
RUN apt install -y cmake
RUN apt install -y libjsoncpp-dev curl libcurl4-openssl-dev libyaml-cpp-dev 
RUN git clone https://github.com/FAIRDataPipeline/cppSimpleModel.git
WORKDIR ${HOME}/cppSimpleModel
RUN cmake -Bbuild
RUN cmake --build build -j4

#Julia Simple Model

WORKDIR ${HOME}
RUN git clone https://github.com/FAIRDataPipeline/DataPipeline.jl.git
WORKDIR "${HOME}/DataPipeline.jl"
#RUN julia -e 'using Pkg; Pkg.instantiate()'
RUN julia -e 'using Pkg; Pkg.add("DataPipeline")'
RUN julia -e 'import Pkg; Pkg.precompile()'
RUN julia -e 'using DataPipeline'


# Java Simple Model
WORKDIR ${HOME}
RUN git clone https://github.com/FAIRDataPipeline/javaSimpleModel.git
WORKDIR "${HOME}/javaSimpleModel"
RUN gradle build

# R Simple Model

WORKDIR ${HOME}
RUN git clone https://github.com/FAIRDataPipeline/rSimpleModel.git
WORKDIR ${HOME}/rSimpleModel
RUN R -e 'install.packages("remotes", repos = "http://cran.us.r-project.org", lib = "/opt/conda/lib/R/library")'
RUN R -e 'install.packages("devtools", repos = "http://cran.us.r-project.org", lib = "/opt/conda/lib/R/library")'
RUN R -e 'install.packages("rDataPipeline", repos = "http://cran.us.r-project.org", lib = "/opt/conda/lib/R/library")'
#RUN R -e 'devtools::install_github("FAIRDataPipeline/rDataPipeline", lib = "/opt/conda/lib/R/library")'
RUN conda install -y -c conda-forge poppler
RUN conda install -y -c conda-forge librsvg
RUN conda install -y -c conda-forge r-magick
RUN conda install -y -c conda-forge glib
RUN R -e 'cat(withr::with_libpaths(new="/opt/conda/lib/R/library", devtools::install_local() ) )'

#Jupyter Iframe
RUN conda install -c conda-forge jupyterlab_iframe
RUN jupyter labextension install jupyterlab_iframe
RUN jupyter serverextension enable --py jupyterlab_iframe

# Permissiona
WORKDIR ${HOME}
RUN chown -R jovyan /opt/julia/
RUN chown -R jovyan /opt/conda/
RUN chown -R jovyan /home/jovyan
COPY ./Notebooks .
