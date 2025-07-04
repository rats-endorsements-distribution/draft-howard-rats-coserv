include tools.mk
include check.mk
include frags.mk

check: check-coserv check-coserv-examples
.PHONY: check

clean: ; rm -f $(CLEANFILES)
.PHONY: clean

$(eval $(call cddl_check_template,coserv,$(COSERV_FRAGS),$(COSERV_EXAMPLES),$(COSERV_IMPORT)))

include subst.mk
include comid.mk
include cmw.mk
