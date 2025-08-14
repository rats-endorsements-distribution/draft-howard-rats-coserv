COSERV_FRAGS := coserv.cddl
COSERV_FRAGS += query.cddl
COSERV_FRAGS += result-set.cddl
COSERV_FRAGS += environment-selector.cddl

COSERV_IMPORT := cmw=cmw-autogen
COSERV_IMPORT += comid=comid-autogen

COSERV_EXAMPLES := $(wildcard examples/rv-*.diag)

COSERV_SIGNED_FRAGS := signed-coserv.cddl
COSERV_SIGNED_FRAGS += signed-coserv-headers.cddl
COSERV_SIGNED_FRAGS += $(COSERV_FRAGS)

COSERV_SIGNED_EXAMPLES := $(subst rv-,signed-rv-,$(COSERV_EXAMPLES))

COSERV_SIGNED_IMPORT := $(COSERV_IMPORT)
