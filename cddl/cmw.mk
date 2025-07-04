# CMW CDDL
github := https://github.com/ietf-rats-wg/
cmw_rel_dl := draft-ietf-rats-msg-wrap/releases/download/
cmw_tag := cddl-draft-ietf-rats-msg-wrap-14
cmw_url := $(join $(github), $(join $(cmw_rel_dl), $(cmw_tag)))

cmw-autogen.cddl: ; $(curl) -LO $(cmw_url)/$@

CLEANFILES += cmw-autogen.cddl
