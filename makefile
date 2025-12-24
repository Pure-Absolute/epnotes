# EP Notes Makefile

CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra
TARGET = epnotes
SRC = src/epnotes.cpp

# Detect OS
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
    LDFLAGS = -lncurses
    INSTALL_DIR = /usr/local/bin
    BINARY = $(TARGET)
endif

ifeq ($(UNAME_S),Darwin)
    LDFLAGS = -lncurses
    INSTALL_DIR = /usr/local/bin
    BINARY = $(TARGET)
endif

ifeq ($(findstring MINGW,$(UNAME_S)),MINGW)
    LDFLAGS = -lpdcurses
    INSTALL_DIR = $(HOME)/bin
    BINARY = $(TARGET).exe
endif

ifeq ($(findstring MSYS,$(UNAME_S)),MSYS)
    LDFLAGS = -lpdcurses
    INSTALL_DIR = $(HOME)/bin
    BINARY = $(TARGET).exe
endif

# Default target
.PHONY: all
all: build

# Build the application
.PHONY: build
build:
	@echo "[*] Building $(TARGET)..."
	$(CXX) $(CXXFLAGS) $(SRC) -o $(BINARY) $(LDFLAGS)
	@echo "[✓] Build complete"

# Install the application
.PHONY: install
install: build
	@echo "[*] Installing $(TARGET)..."
	@mkdir -p $(INSTALL_DIR)
ifeq ($(UNAME_S),Linux)
	@if [ -w $(INSTALL_DIR) ]; then \
		install -Dm755 $(BINARY) $(INSTALL_DIR)/$(BINARY); \
	else \
		sudo install -Dm755 $(BINARY) $(INSTALL_DIR)/$(BINARY); \
	fi
else ifeq ($(UNAME_S),Darwin)
	@if [ -w $(INSTALL_DIR) ]; then \
		install -m755 $(BINARY) $(INSTALL_DIR)/$(BINARY); \
	else \
		sudo install -m755 $(BINARY) $(INSTALL_DIR)/$(BINARY); \
	fi
else
	@cp $(BINARY) $(INSTALL_DIR)/
endif
	@echo "[✓] $(TARGET) installed to $(INSTALL_DIR)"

# Uninstall the application
.PHONY: uninstall
uninstall:
	@echo "[*] Uninstalling $(TARGET)..."
ifeq ($(UNAME_S),Linux)
	@if [ -w $(INSTALL_DIR) ]; then \
		rm -f $(INSTALL_DIR)/$(BINARY); \
	else \
		sudo rm -f $(INSTALL_DIR)/$(BINARY); \
	fi
else ifeq ($(UNAME_S),Darwin)
	@if [ -w $(INSTALL_DIR) ]; then \
		rm -f $(INSTALL_DIR)/$(BINARY); \
	else \
		sudo rm -f $(INSTALL_DIR)/$(BINARY); \
	fi
else
	@rm -f $(INSTALL_DIR)/$(BINARY)
endif
	@echo "[✓] $(TARGET) uninstalled"

# Clean build artifacts
.PHONY: clean
clean:
	@echo "[*] Cleaning build artifacts..."
	@rm -f $(TARGET) $(TARGET).exe *.o
	@echo "[✓] Clean complete"

# Run the application
.PHONY: run
run: build
	./$(BINARY)

# Help target
.PHONY: help
help:
	@echo "EP Notes Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make build      - Build the application"
	@echo "  make install    - Build and install the application"
	@echo "  make uninstall  - Remove the installed application"
	@echo "  make clean      - Remove build artifacts"
	@echo "  make run        - Build and run the application"
	@echo "  make help       - Show this help message"
