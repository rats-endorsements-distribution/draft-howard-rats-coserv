LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update --init
else
ifneq (,$(wildcard $(ID_TEMPLATE_HOME)))
	ln -s "$(ID_TEMPLATE_HOME)" $(LIBDIR)
else
	git clone -q --depth 10 -b main \
	    https://github.com/martinthomson/i-d-template $(LIBDIR)
endif
endif

cddl_deps := cddl/coserv-autogen.cddl
cddl_deps += cddl/comid-autogen.cddl
cddl_deps += cddl/signed-coserv-autogen.cddl
cddl_deps += cddl/discovery-autogen.cddl

$(drafts_xml): $(cddl_deps)

$(cddl_deps): ; $(MAKE) -C cddl check

cddl/%.cddl: cddl/%.cddl.in ; $(MAKE) -C cddl

clean:: ; $(MAKE) -C cddl clean

lint:: http-lint openapi-lint

rfc-http-validate ?= rfc-http-validate
.SECONDARY: $(drafts_xml)
.PHONY: http-lint
http-lint: $(addsuffix .http-lint.txt,$(addprefix .,$(drafts)))
.PHONY: .%.http-lint.txt
.%.http-lint.txt: %.xml $(DEPS_FILES)
	$(trace) $< -s http-lint $(rfc-http-validate) -q $<
	@touch $@

openapi-spec-validator ?= openapi-spec-validator
.SECONDARY: $(drafts_xml)
.PHONY: openapi-lint
openapi-lint: ; $(MAKE) -C openapi check
