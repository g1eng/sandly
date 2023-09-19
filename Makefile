BINDIR = $(PREFIX)/bin
OUTDIR = ./out

all: build

install:
	[ -d $(BINDIR) ] || mkdir -v $(BINDIR)
	install -Dm755 $(OUTDIR)/bin/* $(BINDIR)
build:
	./scripts/build_baseimage.sh
	./scripts/generate_image_contents.sh
	./scripts/generate_apps.sh
	
