# JWK CDDL
jwk_url := https://raw.githubusercontent.com/paulhowardarm/jose-cddl/refs/heads/main/jwk.cddl

jwk-autogen.cddl: ; $(curl) $(jwk_url) > $@

CLEANFILES += jwk-autogen.cddl
