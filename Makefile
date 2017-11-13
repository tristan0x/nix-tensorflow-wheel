CURL ?= curl
DOCKER_COMPOSE ?= docker-compose

DC_CPU_WHEEL_CP_SERVICES = \
	tensorflow-py2-whl \
	tensorflow-py3-whl

DC_GPU_WHEEL_CP_SERVICES = \
	tensorflow-gpu-py2-whl \
	tensorflow-gpu-py3-whl

DC_WHEEL_CP_SERVICES = \
	$(DC_CPU_WHEEL_CP_SERVICES) \
	$(DC_GPU_WHEEL_CP_SERVICES)

DC_WHEEL_BUILD_SERVICES = \
	tensorflow-py2 \
	tensorflow-py3 \
	tensorflow-gpu-py2 \
	tensorflow-gpu-py3

DOCKERFILES = \
	context/Dockerfile.devel \
	context/Dockerfile.devel-gpu \
	context/Dockerfile.devel-py3 \
	context/Dockerfile.devel-gpu-py3 \

CONTEXT_FILES = \
	context/jupyter_notebook_config.py \
	context/run_jupyter.sh

TF_GITHUB_DOCKERFILES = \
	context/Dockerfile.devel.github \
	context/Dockerfile.devel-gpu.github \

TF_GITHUB_RAW = https://raw.githubusercontent.com/tensorflow/tensorflow/master
TF_GITHUB_RECIPE_DIR = tensorflow/tools/docker

all: gpu

gpu: $(DC_GPU_WHEEL_CP_SERVICES)

cpu: $(DC_CPU_WHEEL_CP_SERVICES)

dockerfiles: $(DOCKERFILES)

fetch_github_dockerfiles:
	$(RM) $(TF_GITHUB_DOCKERFILES)
	$(MAKE) $(TF_GITHUB_DOCKERFILES)

# Build container images that will built TensorFlow
$(DC_WHEEL_BUILD_SERVICES):
	$(DOCKER_COMPOSE) build $@

# Build and start containers that will retrieve built wheels
tensorflow-%-whl:
	mkdir -p dist
	export USER_ID=$(shell id -u) GROUP_ID=$(shell id -g) ; \
	$(DOCKER_COMPOSE) up $@ ; \
	$(DOCKER_COMPOSE) rm -fv $@

# Dockerfiles generation for Python 2
context/Dockerfile.devel: context/Dockerfile.devel.github scripts/fetch-tensorflow-recipe
	scripts/fetch-tensorflow-recipe $@

context/Dockerfile.devel-gpu: context/Dockerfile.devel-gpu.github scripts/fetch-tensorflow-recipe
	scripts/fetch-tensorflow-recipe $@

# Dockerfiles generation for Python 3
# Dockerfiles generation for Python 2
context/Dockerfile.devel-py3: context/Dockerfile.devel-gpu.github scripts/fetch-tensorflow-recipe
	scripts/fetch-tensorflow-recipe --three $(@:-py3=)

context/Dockerfile.devel-gpu-py3: context/Dockerfile.devel-gpu.github scripts/fetch-tensorflow-recipe
	scripts/fetch-tensorflow-recipe --three $(@:-py3=)

context/Dockerfile.devel.github context/Dockerfile.devel-gpu.github:
	recipe=$(notdir $@) ; \
	recipe="$${recipe%.github}" ; \
	mkdir -p $(dir $@) ; \
	$(CURL) -L "$(TF_GITHUB_RAW)/$(TF_GITHUB_RECIPE_DIR)/$$recipe" -o $@

# Teach Make the dependency between a Docker image and its Dockerfile
tensorflow-py2: context/Dockerfile.devel
tensorflow-gpu-py2: context/Dockerfile.devel-gpu
tensorflow-py3: context/Dockerfile.devel-py3
tensorflow-gpu-py3: context/Dockerfile.devel-gpu-py3

# Empty files required by Docker recipes
$(CONTEXT_FILES):
	mkdir -p $(dir $@)
	touch $@
