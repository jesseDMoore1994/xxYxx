# This is for C but can easily be modified to work for other languages as well
CC = clang

# Object files go into $(OBJDIR), executables go into $DISTDIR
OBJDIR = build
DISTDIR = dist

# Uncomment next line to overwrite standard malloc library
# WRAP = -Wl,--wrap=malloc -Wl,--wrap=free -Wl,--wrap=calloc -Wl,--wrap=realloc -Wl,--wrap=malloc_usable_size

# Compiler and linker flags
CFLAGS := $(SCM) -Weverything -Werror -Wno-unsafe-buffer-usage -Wno-padded -Wno-declaration-after-statement -Wall -fPIC -g
LFLAGS := $(CFLAGS) -lpthread

# Gathers all header and C files located in the root directory
# in $(HFILES) and $(CFILES), respectively
HFILES := $(wildcard *.h)
CFILES := $(wildcard *.c)
MAIN_CFILES := main.c test.c
NONMAIN_CFILES := $(filter-out $(MAIN_CFILES),$(CFILES))

# Produces in $(OFILES) the names of .o object files for all C files
OFILES := $(patsubst %.c,$(OBJDIR)/%.o,$(CFILES))
MAIN_OFILES := $(patsubst %.c,$(OBJDIR)/%.o,$(MAIN_CFILES))
NONMAIN_OFILES := $(patsubst %.c,$(OBJDIR)/%.o,$(NONMAIN_CFILES))
PROD_OFILES := $(NONMAIN_OFILES) $(OBJDIR)/main.o
TEST_OFILES := $(NONMAIN_OFILES) $(OBJDIR)/test.o

# This a rule that defines how to compile all C files that have changed
# (or their header files) since they were compiled last
$(OBJDIR)/%.o : %.c $(HFILES) $(CFILES)
	$(CC) $(CFLAGS) -c $< -o $@

# Consider these targets as targets, not files
.PHONY : all format clean test

# Build everything: compile all C (changed) files and
# link the object files into an executable (app)
all: dist/xxYxx dist/test

# $(OBJDIR) is an order-only prerequisite:
# only compile if $(OBJDIR) does not exist yet and
# not just because $(OBJDIR) has a new time stamp
$(OFILES): | $(OBJDIR)

# Create directory for $(OBJDIR)
$(OBJDIR):
	mkdir $(OBJDIR)

$(DISTDIR):
	mkdir -p $@

# Build shared library, copy library header file to $(DISTDIR)
$(DISTDIR)/xxYxx: $(DISTDIR) $(OFILES)
	$(CC) $(LFLAGS) $(PROD_OFILES) -o $(DISTDIR)/xxYxx

# Build test executable to validate library
$(DISTDIR)/test: $(DISTDIR) $(OFILES)
	$(CC) $(LFLAGS) $(TEST_OFILES) -o $(DISTDIR)/test

format:
	clang-format -style=google -i *.[ch]

# Clean up by removing the $(OBJDIR) and $(DISTDIR) directories
clean:
	rm -rf $(OBJDIR)
	rm -rf $(DISTDIR)
	rm -rf vgcore.*

test: $(DISTDIR)/test
	valgrind --leak-check=full \
         --show-leak-kinds=all \
         --track-origins=yes \
         $(DISTDIR)/test

