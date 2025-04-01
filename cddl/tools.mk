SHELL := /bin/bash

cddl ?= $(shell command -v cddl)
ifeq ($(strip $(cddl)),)
  $(error cddl tool not found. To install cddl, run: 'gem install cddl')
endif

cddlc ?= $(shell command -v cddlc)
ifeq ($(strip $(cddlc)),)
  $(error cddlc tool not found. To install cddl, run: 'gem install cddlc')
endif

diag2cbor ?= $(shell command -v diag2cbor.rb)
ifeq ($(strip $(diag2cbor)),)
  $(error diag2cbor tool not found. To install diag2cbor, run: 'gem install cbor-diag')
endif

diag2diag ?= $(shell command -v diag2diag.rb)
ifeq ($(strip $(diag2diag)),)
  $(error diag2diag tool not found. To install diag2diag, run: 'gem install cbor-diag')
endif

cbor2pretty ?= $(shell command -v cbor2pretty.rb)
ifeq ($(strip $(cbor2pretty)),)
  $(error cbor2pretty tool not found. To install cbor2pretty, run: 'gem install cbor-diag')
endif

curl ?= $(shell command -v curl)
ifeq ($(strip $(curl)),)
  $(error curl not found.)
endif
