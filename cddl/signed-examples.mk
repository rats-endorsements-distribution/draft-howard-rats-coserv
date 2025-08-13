examples/signed-%.diag: examples/%.diag coserv+cose-template.diag.in
	$(sed) -e '/PAYLOAD/{r $<' -e 'd}' coserv+cose-template.diag.in > $@

.PRECIOUS: examples/signed-%.diag

CLEANFILES += $(wildcard examples/signed-rv-*.*)
