CURRENT_WORKING_DIR=$(shell pwd)

TOOLKIT_IMAGE = quay.io/swade1987/kubernetes-toolkit:1.17.2

kubeval:
	docker run --rm --name kubeval-charts -v $(CURRENT_WORKING_DIR)/charts:/charts $(TOOLKIT_IMAGE) bash -c "`cat bin/kubeval-each-chart`"

deprek8-check:
	docker run --rm --name kubeval-charts -v $(CURRENT_WORKING_DIR)/charts:/charts $(TOOLKIT_IMAGE) bash -c "`cat bin/deprek8s-check`"

sync-repo: configure-gcloud-cli
	./bin/sync-repo.sh

configure-gcloud-cli:
	echo '$(GCLOUD_SERVICE_KEY)' | base64 --decode > /tmp/gcloud-service-key.json
	gcloud auth activate-service-account $(GCLOUD_SERVICE_EMAIL) --key-file=/tmp/gcloud-service-key.json
	gcloud --quiet config set project $(GOOGLE_PROJECT_ID)
	gcloud --quiet config set compute/zone $(GOOGLE_COMPUTE_ZONE)
