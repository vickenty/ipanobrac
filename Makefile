PACKAGES=async cohttp.async
CBFLAGS=$(addprefix -pkg ,$(PACKAGES))

main.native: main.ml
	corebuild $(CBFLAGS) $@
