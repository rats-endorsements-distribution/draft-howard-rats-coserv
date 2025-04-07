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

cddl_deps := cddl/coserv-autogen.cddl cddl/comid-autogen.cddl

$(drafts_xml): $(cddl_deps)

$(cddl_deps): ; $(MAKE) -C cddl check

cddl/%.cddl: cddl/%.cddl.in ; $(MAKE) -C cddl

clean:: ; $(MAKE) -C cddl clean
