PACKAGES=async cohttp.async
CBFLAGS=$(addprefix -pkg ,$(PACKAGES))

main.native: main.ml
	corebuild $(CBFLAGS) $@

clean:
	rm -rf _build *.native test.png
