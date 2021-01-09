ENV_FILE := .env
include ${ENV_FILE}
export $(shell sed 's/=.*//' ${ENV_FILE})
CURRENT_DIR = $(shell pwd)
APP_VERSION := $(shell bash -c "xml sel -N ns='http://maven.apache.org/POM/4.0.0' -t -v '//ns:project/ns:version/text()' $(CURRENT_DIR)/pom.xml")

format:	
	@mvn editorconfig:format

install_jars:
	@mvn -DskipTests clean install

clean:
	@mvn clean

##################################################################
### sample daytrader
##################################################################

image_build_push:
	@docker build --no-cache  --build-arg MAVEN_MIRROR_URL=$(MAVEN_MIRROR_URL) \
  -t $(IMAGE_REPO)/openliberty.sampledaytrader8:"$(APP_VERSION)" -f Dockerfile $(CURRENT_DIR)
	@docker push $(IMAGE_REPO)/openliberty.sampledaytrader8:"$(APP_VERSION)"
	@docker tag $(IMAGE_REPO)/openliberty.sampledaytrader8:"$(APP_VERSION)" $(IMAGE_REPO)/openliberty.sampledaytrader8
	@docker push "$(IMAGE_REPO)"/openliberty.sampledaytrader8

.PHONY:	all
all:	clean install_jars	image_build_push	qp_jvm_image_build_push	tos_jvm_image_build_push	tradr_image_build_push