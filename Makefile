.PHONY: clean-test minimal-version-test dune-clean-build-test-clean ci-switch ci-clean-switch


.ONESHELL:
.SHELLFLAGS := -eu -c

SWITCH_NAME ?= TEST_quickterface
OPAM_WITH_SWITCH ?= OPAMSWITCH=$(SWITCH_NAME)
OPAM_IN_SWITCH ?= $(OPAM_WITH_SWITCH) opam exec --

MINIMAL_VERSION_OPTION_CRITERIA ?= "+removed,+count[version-lag,solution]"
MINIMAL_VERSION_OPTIONS ?= OPAMCRITERIA=$(MINIMAL_VERSION_OPTION_CRITERIA) OPAMFIXUPCRITERIA=$(MINIMAL_VERSION_OPTION_CRITERIA) OPAMUPGRADECRITERIA=$(MINIMAL_VERSION_OPTION_CRITERIA)

clean-test:
	trap '$(MAKE) ci-clean-switch >/dev/null 2>&1 || true' EXIT INT TERM
	$(MAKE) ci-switch
	$(OPAM_WITH_SWITCH) opam install --yes --deps-only . --with-test
	$(MAKE) dune-clean-build-test-clean

minimal-version-test:
	trap '$(MAKE) ci-clean-switch >/dev/null 2>&1 || true' EXIT INT TERM
	$(MAKE) ci-switch
	opam option solver=builtin-0install
	$(OPAM_WITH_SWITCH) opam pin add -yn quickterface .
	$(OPAM_WITH_SWITCH) $(MINIMAL_VERSION_OPTIONS) opam reinstall --yes quickterface --with-test
	opam option solver=
	$(MAKE) dune-clean-build-test-clean

dune-clean-build-test-clean:
	$(OPAM_IN_SWITCH) dune clean
	$(OPAM_IN_SWITCH) dune build @all
	$(OPAM_IN_SWITCH) dune runtest
	$(OPAM_IN_SWITCH) dune clean

ci-switch:
	@test -n "$(OCAML_VERSION)" || { echo "Error: OCAML_VERSION is not set" >&2; exit 1; }
	opam switch create $(SWITCH_NAME) "$(OCAML_VERSION)" --no-switch

ci-clean-switch:
	if opam switch list --short | grep -Fxq "$(SWITCH_NAME)"; then \
		opam switch remove "$(SWITCH_NAME)" --yes; \
	fi
