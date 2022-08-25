# RSECon22 Walktrhough: A FAIR Data Pipeline: provenance-driven data management for traceable scientific workflows

This repo contains the material for the RSECon22 walkthrough titled: A FAIR Data Pipeline: provenance-driven data management for traceable scientific workflows. The walkthrough uses a docker containter an Jupyter Labs (formally notebook) to run through an example usage of the FAIR DataPipeline.

## Prerequisites
The only prerequisite is an installation of Docker, Docker is available free from [docker.com](https://www.docker.com/).

## Running the Docker Container
The docker container is available on the GitHub Registry and can be pulled using the following command:

```
docker pull ghcr.io/fairdatapipeline/rsecon:latest
```

The container can then be run using the following command:

```
docker run -p 8000:8000 -p 8888:8888
```
Once the container has started, there will be an address to access the Jupyter Lab within the console, this address with include a token for authentication to the Jupyter Labs page. The link will take the form of: `http://127.0.0.1:8888/lab?token=<token>`.

This address can then be accessed through your web browser to give you access to the Jupyter Lab installation.

N.B. The container will bind the ports `8000` and `8888` so please make sure these ports are available.

Some package requirements and packages have been pre-installed in the interest of saving time.

## Jupyter Notebooks
The docker container contains 8 Jupyter Notebooks detailed below.

## CLI and Registry Installation

### 1_registry_cli_install.ipynb
This notebook contains codeblocks to install the FAIR Command Line Interface (CLI) and the FAIR Local Registry.

## Simple Models
The notebooks contain code blocks to run the SEIRS model example in different languages, they contain code to `register` inputs and `run` the models.

All the models use the same input and therefor the  `pull` code block only needs to run from one of the files.

### 2a_python.ipynb
Code blocks to clone the simple model repo, install the simple model package, initalise a Fair repository, register ('pull') the inputs for the model and then 'run' the model in python.

### 2b_cpp.ipynb
Code blocks to initialise a fair repository, register ('pull') the inputs for the model and then 'run' the model in C++. The C++ repo has already been cloned and the executable has been compiled.

### 2c_java.ipynb
Code blocks to initialise a fair repository, register ('pull') the inputs for the model and then 'run' the model in JAVA. The Jave repo has already been cloned and the project pre built.

### 2d_julia.ipynb
Code blocks to initialise a fair repository, register ('pull') the inputs for the model and then 'run' the model in Julia. The Julia repository has been cloned into the docker container and the julia package has already been initialised.

### 2e_r.ipynb
Code blocks to initialise a fair repository, register ('pull') the inputs for the model and then 'run' the model in R. The R repo has already been cloned and the R Package installed

## Comparison of the Simple Models
The SEIRS models can be compared and graphed using the following notebook.

### 3_comparison.ipynb
Code block to `run` a comparison of the simple models producing a graph.

## Explore the registry
The local registry can be explored by running it and navigating to the web interface.

### 4_start_registry
Notebook to start and stop registry



