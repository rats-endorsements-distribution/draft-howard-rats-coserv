SRCS := $(wildcard *.txt)
SVGS := $(SRCS:.txt=.svg)
PDFS := $(SRCS:.txt=.pdf)

%.svg: %.txt ; aasvg < $< > $@

CLEANFILES += $(SVGS)

%.pdf: %.svg ; rsvg-convert -f pdf -o $@ $<

CLEANFILES += $(PDFS)

all: $(PDFS)

clean: ; $(RM) -f $(CLEANFILES)

svg: $(SVGS)
