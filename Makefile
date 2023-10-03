setup:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
build:
	@echo 'up -d --build' && \
		cd .devcontainer/ && \
		docker-compose up -d --build
	
in_php:
	. ./.envrc && \
	docker exec -it $(APP_NAME)-php bash

remove_all:
	@echo 'docker-compose down --rmi all --volumes --remove-orphan'
		docker-compose down --rmi all --volumes --remove-orphan

clean-none-images:
    docker rmi $(docker images -f "dangling=true" -q)
