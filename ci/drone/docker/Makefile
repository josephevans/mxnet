
ECR_REPO=187885003319.dkr.ecr.us-west-2.amazonaws.com/mxnetci

DOCKER_LOGIN:=$(shell $$(aws ecr get-login --no-include-email --region us-west-2))

BASE_IMAGES:=$(shell ls Dockerfile.*-base)
CHILD_IMAGES:=$(shell ls Dockerfile.* | grep -v "\-base")

IMAGES=$(subst Dockerfile.,,$(BASE_IMAGES) $(CHILD_IMAGES))

#ubuntu1804_cpu-base \
#       ubuntu1804_cpu \
#       ubuntu1804_cpu-java \
#       ubuntu1804_cpu-clojure \
#       ubuntu1804_cpu-julia \
#       ubuntu1804_cpu-scala \
#       ubuntu1804_cpu-r \
#       ubuntu1804_gpu-base \
#       ubuntu1804_gpu \
#       ubuntu1804_gpu-java \
#       ubuntu1804_gpu-clojure \
#       ubuntu1804_gpu-julia \
#       ubuntu1804_gpu-scala \
#       ubuntu1804_gpu-r

all: $(IMAGES)

%: Dockerfile.%
	docker build -t mxnetci/$(subst _,:,$@) -f $< .
	docker tag mxnetci/$(subst _,:,$@) $(ECR_REPO)/$(subst _,:,$@)
	docker push $(ECR_REPO)/$(subst _,:,$@)


