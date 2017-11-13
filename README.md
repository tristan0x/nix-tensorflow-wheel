# TensorFlow wheel builder

This project provides a set of scripts to build the latest versions
of TensorFlow in a consistent way.

It bypasses the official [TensorFlow scripts](https://github.com/tensorflow/tensorflow/tree/master/tensorflow/tools/docker) to handle the Blue Brain Project requirements:

* Python 2 and Python 3 (not necessarily the version shipped with ubuntu 16.04)
* Vectorization support on HPC cluster
* GPU support

Interface is a Makefile providing the following top targets:

* tensorflow-py2-whl: Build TensorFlow with Python 2.7
* tensorflow-py3-whl: Build TensorFlow with Python 3.4
* tensorflow-gpu-py2-whl: Build TensorFlow with GPU support and Python 2.7
* tensorflow-gpu-py3-whl: Build TensorFlow with GPU support and Python 3.4
* gpu: build the 2 GPU targets above
* cpu: build the 2 other targets
* all: build the 4 Python wheels (default target)

## Environment variables

You can use the environment variables below to customize the behavior:

* PYTHON3_VERSION: Python 3 version to use, default is "3.4"
* DOCKER_COMPOSE: path to `docker-compose` executable (default "docker-compose")
* SED: path to `sed` executable
* CURL: path to `curl` executable

## Update Docker recipes

* To take benefits of new changes added to TensorFlow official Dockerfiles, use
  the `fetch_github_recipes` make target.
* Then you can rebuild the Dockerfiles used by this application with the
  `dockerfiles` make target.

For instance:

```sh
$ make fetch_github_recipes
$ make dockerfiles
$ git diff
$ make
```

Commands above will:

1. Grab latest TensorFlow official Dockerfiles
1. Patch these Dockerfiles to create those used by this project
1. Show the difference
1. Build all Python wheels

## C/C++ compilation flags

You can customize compilation flags in `docker-compose.yaml` thru the
`cflags` variable. Default value is for the Blue Brain Project
*analysis & visualization* cluster.

# LICENSE

This project is released under the MIT License.
See [LICENSE](./LICENSE) file for more information
