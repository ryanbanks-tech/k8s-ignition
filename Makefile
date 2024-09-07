# Define the Go binary name
BINARY_NAME=filter-secrets

# Default target executed when no arguments are provided to 'make'
all: build

# Build the Go project
build:
	@echo "Building the go project..."
	go build -o $(BINARY_NAME) filter-secrets.go

# Clean the build artifacts
clean:
	@echo "Cleaning up..."
	@rm -f $(BINARY_NAME)

# Run the Go project
run: build
	@echo "Running the go project..."
	./$(BINARY_NAME)

# Run tests
test:
	@echo "Running tests..."
	go test ./...

# Help command to display available targets
help:
	@echo "Makefile targets:"
	@echo "  make build   - Build the go project"
	@echo "  make clean   - Remove build artifacts"
	@echo "  make run     - Build and run the go project"
	@echo "  make test    - Run tests"
	@echo "  make help    - Display this help message"
