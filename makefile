SHELL := /bin/bash

# ==============================================================================
# Containers

VERSION := 1.0

all: salescart-api

salescart-api:
	docker build \
	-f zarf/docker/dockerfile.salescart-api \
	-t salescart-api-amd64:${VERSION} \
	--build-arg BUILD_REF=${VERSION} \
	--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	.

# ==============================================================================
# Running from within k8s/kind

KIND_CLUSTER := salescart

kind-up:
	kind create cluster \
		--image kindest/node:v1.21.1@sha256:69860bda5563ac81e3c0057d654b5253219618a22ec3a346306239bba8cfa1a6 \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml

kind-load:
	cd zarf/k8s/kind/salescart-pod; kustomize edit set image salescart-api-image=salescart-api-amd64:$(VERSION)
	kind load docker-image salescart-api-amd64:$(VERSION) --name $(KIND_CLUSTER)

kind-apply:
	kustomize build zarf/k8s/kind/salescart-pod | kubectl apply -f -

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

kind-status-salescart:
	kubectl get pods -o wide --watch --namespace=salescart-system

kind-logs:
	kubectl logs -l app=salescart --all-containers=true -f --tail=100 --namespace=salescart-system

kind-restart:
	kubectl rollout restart deployment salescart-pod --namespace=salescart-system

kind-update: all kind-load kind-restart

kind-update-apply: all kind-load kind-apply

kind-describe:
	kubectl describe pod -l app=salescart --namespace=salescart-system

# ==============================================================================
# Modules support

tidy:
	go mod tidy
	go mod vendor
