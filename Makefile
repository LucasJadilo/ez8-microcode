################################################################################
#  EZ8 Microcode                                                               #
################################################################################

TITLE := EZ8 Microcode

VERSION_MAJOR := 1
VERSION_MINOR := 0
VERSION_PATCH := 0
VERSION_PRE   :=
VERSION_META  :=

ifneq ($(VERSION_PRE),)
    _VERSION_PRE := -$(VERSION_PRE)
endif

ifneq ($(VERSION_META),)
    _VERSION_META := +$(VERSION_META)
endif

VERSION_BASE := $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
VERSION      := $(VERSION_BASE)$(_VERSION_PRE)$(_VERSION_META)

.PHONY: version
version:
	$(info $(VERSION))
	-@cd .

#------------------------------------------------------------------------------#
#  Util                                                                        #
#------------------------------------------------------------------------------#

ifeq ($(OS),Windows_NT)
    EXE_SUFFIX := _win
    ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
        EXE_SUFFIX := $(EXE_SUFFIX)_amd64
    else ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
        EXE_SUFFIX := $(EXE_SUFFIX)_amd64
    else ifeq ($(PROCESSOR_ARCHITECTURE),x86)
        EXE_SUFFIX := $(EXE_SUFFIX)_ia32
    endif
    EXE_SUFFIX := $(EXE_SUFFIX).exe
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        EXE_SUFFIX := _linux
    else ifeq ($(UNAME_S),Darwin)
        EXE_SUFFIX := _macos
    endif
    UNAME_P := $(shell uname -p)
    ifeq ($(UNAME_P),x86_64)
        EXE_SUFFIX := $(EXE_SUFFIX)_amd64
    else ifneq ($(filter %86,$(UNAME_P)),)
        EXE_SUFFIX := $(EXE_SUFFIX)_ia32
    else ifneq ($(filter arm%,$(UNAME_P)),)
        EXE_SUFFIX := $(EXE_SUFFIX)_arm
    endif
endif

ifeq ($(shell uname 2>nul),) # Use Command Prompt syntax (Windows)
    MKDIR  = if not exist $(subst /,\,$(1)) mkdir $(subst /,\,$(1))
    RMDIR  = rmdir /s /q $(subst /,\,$(1)) 1>nul 2>nul || rem
    RMFILE = del /s /q $(subst /,\,$(1)) 1>nul 2>nul
else # Use Bash syntax
    $(shell rm -f nul 2>/dev/null) # Delete file `nul` created by `uname 2>nul`
    MKDIR  = mkdir -p $(1)
    RMDIR  = rm -rf $(1)
    RMFILE = rm -rf $(1)
endif

FONT_RESET      := [0m
FONT_BOLD_GREEN := [1;32m

MAKEFILE := Makefile # Name of this makefile

E :=#       Useful for inserting whitespace where literal whitespace would not be possible
S := $E $E# Useful for inserting a space character where a literal space would not be possible
C := ,#     Useful for inserting a comma character where a literal comma would not be possible
define N #  Useful for inserting a new line where a literal line break would not be possible


endef

#------------------------------------------------------------------------------#
#  Help                                                                        #
#------------------------------------------------------------------------------#

.DEFAULT_GOAL := help
.PHONY: help
help:
	$(info $NUsage: make [TARGET]... [VARIABLE=VALUE]...)
	$(info $NTargets:$N)
	$(info $E   help      Print this help menu)
	$(info $E   version   Print only the project's full version)
	$(info $E   all       Compile sources and generate executable)
	$(info $E   run       Compile sources and run executable (see variable RUN_ARGS))
	$(info $E   format    Format sources with clang-format)
	$(info $E   lint      Analyze sources with cppcheck)
	$(info $E   clean     Delete all files and directories generated during compilation)
	$(info $NVariables:$N)
	$(info $E   RUN_ARGS           Command line arguments that will be passed to the program (default: empty))
	$(info $E   TOOLCHAIN_PREFIX   Define a prefix for the toolchain commands gcc, ar, ... (default: empty))
	-@cd .

#------------------------------------------------------------------------------#
#  Banner                                                                      #
#------------------------------------------------------------------------------#

define BANNER
$(FONT_BOLD_GREEN)--------------------------------------------------------------------------------
 $(TITLE) $(VERSION)
--------------------------------------------------------------------------------$(FONT_RESET)
endef

ifeq ($(filter version,$(MAKECMDGOALS)),)
    $(info $(BANNER))
endif

#------------------------------------------------------------------------------#
#  Build                                                                       #
#------------------------------------------------------------------------------#

LIB_VERSION := 1.0.0

SRC_DIR   := src
LIB_DIR   := lib
LIB_H_DIR := $(LIB_DIR)/src
LIB_A_DIR := $(LIB_DIR)/build/lib
INC_DIRS  := $(SRC_DIR) $(LIB_H_DIR)
BUILD_DIR := build
OBJ_DIR   := $(BUILD_DIR)/obj
EXE_DIR   := $(BUILD_DIR)/exe

LIB_MAKEFILE := $(LIB_DIR)/Makefile
LIB_A_FILE   := $(LIB_A_DIR)/libez8_$(LIB_VERSION).a
SRC_FILES    := $(wildcard $(SRC_DIR)/*.c)
OBJ_FILES    := $(patsubst %.c,$(OBJ_DIR)/%.o,$(notdir $(SRC_FILES)))
DEP_FILES    := $(patsubst %.o,%.d,$(OBJ_FILES))
EXE_FILE     := $(EXE_DIR)/ez8_microcode_$(VERSION)$(EXE_SUFFIX)

VPATH := $(sort $(dir $(SRC_FILES)))

CC   := $(TOOLCHAIN_PREFIX)gcc
SIZE := $(TOOLCHAIN_PREFIX)size

CPP_FLAGS = \
$(addprefix -I ,$(INC_DIRS)) \
-MMD \
-MP \
-MF $(patsubst %.o,%.d,$@) \
-MT $@ \
-D APP_VERSION_MAJOR=$(VERSION_MAJOR) \
-D APP_VERSION_MINOR=$(VERSION_MINOR) \
-D APP_VERSION_PATCH=$(VERSION_PATCH)

ifneq ($(VERSION_PRE),)
    CPP_FLAGS += -D APP_VERSION_PRE=\"$(VERSION_PRE)\"
endif

ifneq ($(VERSION_META),)
    CPP_FLAGS += -D APP_VERSION_META=\"$(VERSION_META)\"
endif

C_FLAGS := \
-c \
-O2 \
-std=c99 \
-Wall \
-Wextra \
-Wpedantic \
-Wshadow \
-Wfloat-equal \
-Wdouble-promotion \
-Wundef \
-Wstrict-prototypes \
-Wswitch-default \
-Wunreachable-code \
-Wwrite-strings \
-Wformat=2 \
-Wconversion \
-Wcast-align \
-Wpointer-arith \
-fno-common \
-save-temps \
-fverbose-asm \
-fstack-usage \
-ffunction-sections \
-fdata-sections \
-Werror

LD_FLAGS := \
-Wl,--gc-sections \
-L $(LIB_A_DIR) \
-l:$(notdir $(LIB_A_FILE))

.PHONY: all
all: $(EXE_FILE)

.PHONY: run
run: $(EXE_FILE)
	$(info $N$(FONT_BOLD_GREEN)Running: $<$(FONT_RESET))
	$(EXE_FILE) $(RUN_ARGS)

$(EXE_FILE): $(LIB_A_FILE) $(OBJ_FILES) $(MAKEFILE) | $(EXE_DIR)
	$(info $N$(FONT_BOLD_GREEN)Linking: $@$(FONT_RESET))
	$(CC) -o $@ $(OBJ_FILES) $(LD_FLAGS)
	$(SIZE) $@

$(LIB_A_FILE): $(MAKEFILE) | $(LIB_MAKEFILE)
	$(info $N$(FONT_BOLD_GREEN)Building library: $@$(FONT_RESET))
	'$(MAKE)' -C $(LIB_DIR) all

$(LIB_MAKEFILE):
	git submodule update --init --recursive $(LIB_DIR)
	cd $(LIB_DIR) && git restore .

$(OBJ_FILES): $(OBJ_DIR)/%.o: %.c $(OBJ_DIR)/%.d $(MAKEFILE) | $(OBJ_DIR)
	$(info $N$(FONT_BOLD_GREEN)Compiling: $@$(FONT_RESET))
	$(CC) $(CPP_FLAGS) $(C_FLAGS) -o $@ $<

$(EXE_DIR) $(OBJ_DIR):
	$(info $N$(FONT_BOLD_GREEN)Creating directory: $@$(FONT_RESET))
	$(call MKDIR,$@)

$(DEP_FILES):

-include $(wildcard $(DEP_FILES))

#------------------------------------------------------------------------------#
#  Formatting                                                                  #
#------------------------------------------------------------------------------#

FORMAT_DIRS  := $(SRC_DIR)
FORMAT_FILES := $(wildcard $(addsuffix /*.c,$(FORMAT_DIRS)) $(addsuffix /*.h,$(FORMAT_DIRS)))

.PHONY: format
format:
	$(info $N$(FONT_BOLD_GREEN)Formatting sources$(FONT_RESET))
	clang-format -i $(FORMAT_FILES)

#------------------------------------------------------------------------------#
#  Code Analysis                                                               #
#------------------------------------------------------------------------------#

LINT_DIRS  := $(SRC_DIR)
LINT_FLAGS := \
--platform=native \
--std=c99 \
--check-level=exhaustive \
--enable=all \
--suppress=missingIncludeSystem \
--showtime=file-total \
$(addprefix -I ,$(INC_DIRS))

.PHONY: lint
lint:
	$(info $N$(FONT_BOLD_GREEN)Analyzing sources$(FONT_RESET))
	cppcheck $(LINT_FLAGS) $(LINT_DIRS)

#------------------------------------------------------------------------------#
#  Clean                                                                       #
#------------------------------------------------------------------------------#

.PHONY: clean
clean:
	$(info $N$(FONT_BOLD_GREEN)Cleaning directory$(FONT_RESET))
	'$(MAKE)' -C $(LIB_DIR) clean
	$(call RMDIR,$(BUILD_DIR))

################################# END OF FILE ##################################
