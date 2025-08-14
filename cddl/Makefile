include tools.mk
include check.mk
include frags.mk

check:: check-coserv check-coserv-examples
check:: check-signed-coserv check-signed-coserv-examples
.PHONY: check

clean: ; rm -f $(CLEANFILES)
.PHONY: clean

$(eval $(call cddl_check_template,coserv,$(COSERV_FRAGS),$(COSERV_EXAMPLES),$(COSERV_IMPORT)))
$(eval $(call cddl_check_template,signed-coserv,$(COSERV_SIGNED_FRAGS),$(COSERV_SIGNED_EXAMPLES),$(COSERV_SIGNED_IMPORT)))

include signed-examples.mk
include subst.mk
include comid.mk
include cmw.mk
