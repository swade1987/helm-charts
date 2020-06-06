# Helm charts

This repository contains the source for the packaged and versioned charts released in the [`gs://swade1987-charts`](https://console.cloud.google.com/storage/browser/swade1987-charts/).

The charts in the `charts/` directory in the `master` branch match the latest packaged charts in the chart repository.

The purpose of this repository is to provide a place for maintaining and contributing swade1987 specific charts, with CI processes in place for managing the releasing of charts into the repository.

## How do I enable the swade1987 repository for Helm?

To add the swade1987 chart repository for your local client, run the following:

```
$ helm repo add swade1987 https://swade1987-charts.storage.googleapis.com

"swade1987" has been added to your repositories
```

You can then run `helm search repo swade1987` to see the charts and their available versions.

You can now install charts using `helm install swade1987/<chart>`. 

For more information on using Helm, refer to the [Helm documentation](https://github.com/kubernetes/helm#docs).

## Supported Kubernetes Versions

This chart repository supports the latest and previous minor versions of Kubernetes.

For example, if the latest minor release of Kubernetes is 1.18 then 1.17 and 1.18 are supported.

## Linting

https://github.com/helm/chart-testing is being used as the helm linting container image.