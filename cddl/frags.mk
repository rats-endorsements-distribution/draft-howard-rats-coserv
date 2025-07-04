COSERV_FRAGS := coserv.cddl
COSERV_FRAGS += query.cddl
COSERV_FRAGS += result-set.cddl
COSERV_FRAGS += environment-selector.cddl
COSERV_FRAGS += signed-coserv-headers.cddl

COSERV_IMPORT := cmw=cmw-autogen
COSERV_IMPORT += comid=comid-autogen

COSERV_EXAMPLES := $(wildcard examples/*.diag)
