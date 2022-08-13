CC=g++

LIBS=glib-2.0 gio-2.0

DEBUG_CFLAGS=-Wextra -g -Og -std=gnu++17 $(shell pkg-config --cflags $(LIBS))
RELEASE_CFLAGS=-Wextra -O2 -DNDEBUG -std=gnu++17 $(shell pkg-config --cflags $(LIBS))
LD_FLAGS=$(shell pkg-config --libs $(LIBS))

SRC_DIR=src/
OBJ_DIR=obj/
BIN_DIR=bin/
BIN_INSTALL_DIR=/usr/local/bin/

SRC_FILE_EXT=c

# TODO: Make portable, SRCS relies on shell
SRCS:=$(shell find $(SRC_DIR) -name '*.${SRC_FILE_EXT}')
OBJS:=$(patsubst $(SRC_DIR)%.${SRC_FILE_EXT}, $(OBJ_DIR)%.o, $(SRCS))
OBJ_DIRS:=$(sort $(dir $(OBJS)))

BIN=$(BIN_DIR)wp-changer

.PHONY: all
all: debug

.PHONY: debug
debug: CFLAGS=$(DEBUG_CFLAGS)
debug: $(BIN)

.PHONY: release
release: clean
release: CFLAGS=$(RELEASE_CFLAGS)
release: $(BIN)

# Create directories for objects
$(OBJ_DIRS):
	mkdir -p $@

# Create directory for binary file
$(BIN_DIR):
	mkdir -p $@

# Compile C files to objects
$(OBJS): $(SRCS) $(OBJ_DIRS)
	$(CC) $(CFLAGS) -c $(patsubst $(OBJ_DIR)%.o, $(SRC_DIR)%.${SRC_FILE_EXT}, $@) -o $@

# Link objects to binary
$(BIN): $(BIN_DIR) $(OBJS)
	$(CC) ${LD_FLAGS} -o $@ $(OBJS)

.PHONY: clean
clean:
	rm -rf $(dir $(BIN))*
	rm -rf $(OBJ_DIR)*

# Obviously broken on NixOS D:
.PHONY: install
install: release
	install $(BIN) $(BIN_INSTALL_DIR)

.PHONY: package
package: clean
	cd .. && tar -zcf $(notdir $(CURDIR)).tar.gz ./$(notdir $(CURDIR))
