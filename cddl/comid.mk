include tools.mk

# CoMID CDDL
github := https://github.com/thomas-fossati/
comid_rel_dl := draft-ietf-rats-corim/releases/download/
comid_tag := v0.0.0rc1
comid_url := $(join $(github), $(join $(comid_rel_dl), $(comid_tag)))

comid-autogen.cddl: ; $(curl) -LO $(comid_url)/$@

CLEANFILES += comid-autogen.cddl
