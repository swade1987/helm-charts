CURRENT_WORKING_DIR=$(shell pwd)

TOOLKIT_IMAGE = quay.io/swade1987/kubernetes-toolkit:1.17.2

kubeval:
	docker run --rm --name kubeval-charts -v $(CURRENT_WORKING_DIR)/charts:/charts $(TOOLKIT_IMAGE) bash -c "`cat bin/kubeval-each-chart`"

deprek8-check:
	docker run --rm --name kubeval-charts -v $(CURRENT_WORKING_DIR)/charts:/charts $(TOOLKIT_IMAGE) bash -c "`cat bin/deprek8s-check`"