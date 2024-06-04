# Definition of phony targets
.PHONY: build start exec stop clean help

# import variables
include .env

# Function to format port mappings
define ports
$(foreach port, $(PORTS), -p $(port))
endef

# Target to build the Docker image
# -> Build the image from the Dockerfile in the current directory
# -> Do not use cache during the build process
build:
	docker build -t $(IMAGE) . --no-cache

# Target to start a container from the built Docker image
# -> Run a container in detached mode with an interactive terminal, privileged access, and port mappings
# -> Execute the script /startup.sh inside the container, which starts the Python filter script
start:
	docker run -itd --name $(CONTAINER) --privileged $(call ports) $(IMAGE)
	docker exec $(CONTAINER) /startup.sh

# Target to open an interactive Bash shell in the container
shell:
	docker exec -it $(CONTAINER) /bin/bash

# Target to stop and remove the running container
stop:
	docker stop $(CONTAINER)
	docker rm $(CONTAINER)

# Target to remove the Docker image
clean:
	docker rmi $(IMAGE)

# Help target to display available commands
help:
	@echo "Available commands:"
	@echo "  build  ->  Build the Docker image"
	@echo "  start  ->  Start the Docker container and the filter"
	@echo "  shell  ->  Open an interactive Bash shell in the running container"
	@echo "  stop   ->  Stop and remove the running container"
	@echo "  clean  ->  Remove the Docker image"
	@echo "  help   ->  Display this help message"
