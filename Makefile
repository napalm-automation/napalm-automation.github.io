CONTAINER_NAME := "napalm-automation-jekyll"

.PHONY: purge
purge:
ifeq ($(TRAVIS_BRANCH),master)
	@curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$(CLOUDFLARE_ZONE_ID)/purge_cache" -H "X-Auth-Email: $(CLOUDFLARE_EMAIL)" -H "X-Auth-Key: $(CLOUDFLARE_API_TOKEN)" -H "Content-Type: application/json" --data '{"purge_everything":true}'
endif

.PHONY: docker
docker:
	docker build . --tag napalm-automation-jekyll:latest

.PHONY: serve
serve: stop
	docker run -it --name $(CONTAINER_NAME) \
		-p 4000:4000 \
		-v $(PWD):/srv/jekyll \
		napalm-automation-jekyll:latest \
		jekyll serve --config _config.yml,_config-dev.yml --future --drafts

.PHONY: stop
stop:
	@docker rm $(CONTAINER_NAME) -f || exit 0
