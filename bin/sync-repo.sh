#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly HELM_URL=https://storage.googleapis.com/kubernetes-helm
readonly HELM_TARBALL=helm-v2.16.5-linux-amd64.tar.gz
readonly REPO_URL=https://swade1987-charts.storage.googleapis.com/
readonly GCS_BUCKET=gs://swade1987-charts

main() {
  setup_helm_client

  if ! sync_repo charts "$GCS_BUCKET" "$REPO_URL"; then
      log_error "Not all charts could be packaged and synced!"
  fi
}

setup_helm_client() {
  echo "Setting up Helm client..."

  curl --user-agent curl-ci-sync -sSL -o "$HELM_TARBALL" "$HELM_URL/$HELM_TARBALL"
  tar xzfv "$HELM_TARBALL"

  PATH="$(pwd)/linux-amd64/:$PATH"

  helm init --client-only
}

sync_repo() {
  local repo_dir="${1?Specify repo dir}"
  local bucket="${2?Specify repo bucket}"
  local repo_url="${3?Specify repo url}"
  local sync_dir="${repo_dir}-sync"
  local index_dir="${repo_dir}-index"

  echo "Syncing repo '$repo_dir'..."

  mkdir -p "$sync_dir"
  mkdir -p "$index_dir"

  # Copy the index.yaml file from the bucket.
  if ! gsutil cp "$bucket/index.yaml" "$index_dir/index.yaml"; then
    log_error "Exiting because unable to copy index locally. Not safe to proceed."
    exit 1
  fi

  local return_value=0

  # Loop around each chart and package.
  for dir in "$repo_dir"/*; do
    if helm dependency build "$dir"; then
      helm package --destination "$sync_dir" "$dir"
    else
      log_error "Problem building dependencies. Skipping packaging of '$dir'."
      return_value=1
    fi
  done

  if helm repo index --url "$repo_url" --merge "$index_dir/index.yaml" "$sync_dir"; then

    # Move updated index.yaml to sync folder so we don't push the old one again
    mv -f "$sync_dir/index.yaml" "$index_dir/index.yaml"

    # Push all the local chart tarballs to the bucket.
    gsutil -m rsync "$sync_dir" "$bucket"

    # Make sure index.yaml is synced last
    gsutil cp "$index_dir/index.yaml" "$bucket"

    # Set the metadata on all objects in the bucket.
    # See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control for more info.
    gsutil -m setmeta -h "Cache-Control:no-cache" "$bucket"/*.tgz
    gsutil -m setmeta -h "Cache-Control:no-cache" "$bucket"/index.yaml

  else
    log_error "Exiting because unable to update index. Not safe to push update."
    exit 1
  fi

  ls -l "$sync_dir"

  return "$return_value"
}


log_error() {
    printf '\e[31mERROR: %s\n\e[39m' "$1" >&2
}

main