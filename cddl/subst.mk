signed-coserv-headers.cddl: signed-coserv-headers.cddl.in ; sed -e 's/TBD1/10000/' $< > $@

CLEANFILES += signed-coserv-headers.cddl
