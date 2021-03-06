# Also needs to be updated in galaxy.yml
VERSION = 0.1.0

# To run sanity tests in a venv, set SANITY_TEST_ARGS to '--venv'
SANITY_TEST_ARGS ?= --docker --color

clean:
	rm -f community-okd-$(VERSION).tar.gz
	rm -rf ansible_collections

build: clean
	ansible-galaxy collection build

install-kubernetes-src:
	mkdir -p ansible_collections/community/kubernetes
	rm -rf ansible_collections/community/kubernetes/*
	curl -L https://github.com/ansible-collections/community.kubernetes/archive/main.tar.gz | tar -xz -C ansible_collections/community/kubernetes --strip-components 1

# TODO: Once we no longer rely on features in main we should drop the install-kubernetes-src dependency
install: build install-kubernetes-src
	ansible-galaxy collection install -p ansible_collections community-okd-$(VERSION).tar.gz

test-sanity: install
	cd ansible_collections/community/okd && ansible-test sanity --exclude ci/ -v $(SANITY_TEST_ARGS)

test-integration: install
	molecule test

test-integration-incluster: test-integration-incluster-upstream test-integration-incluster-downstream

test-integration-incluster-upstream:
	./ci/incluster_integration_upstream.sh

test-integration-incluster-downstream:
	./ci/incluster_integration_downstream.sh

downstream-test-sanity:
	./ci/downstream.sh -s

downstream-test-integration:
	./ci/downstream.sh -i

downstream-build:
	./ci/downstream.sh -b

