CURRENT_WORKING_DIR=$(shell pwd)

GCLOUD_SERVICE_KEY ?="unknown"
GCLOUD_SERVICE_EMAIL := circle-ci@swade1987.iam.gserviceaccount.com
GOOGLE_PROJECT_ID := swade1987
GOOGLE_COMPUTE_ZONE := europe-west2-a

TOOLKIT_IMAGE = eu.gcr.io/swade1987/kubernetes-toolkit:1.17.2

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
