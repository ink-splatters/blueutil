CFLAGS = -Wall -Wextra -Werror -mmacosx-version-min=10.9 -framework Foundation -framework IOBluetooth

DESTDIR =
prefix = /usr/local
bindir = $(prefix)/bin
INSTALL = install
INSTALL_PROGRAM = $(INSTALL) -m 755

build: blueutil

format:
	clang-format -i *.m

test: build
	./test

clean:
	$(RM) blueutil

install: build
	$(INSTALL_PROGRAM) blueutil $(DESTDIR)$(bindir)/blueutil

uninstall:
	$(RM) $(DESTDIR)$(bindir)/blueutil

.PHONY: build format test clean install uninstall
