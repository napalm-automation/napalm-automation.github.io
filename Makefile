.PHONY: purge
purge:
ifeq ($(TRAVIS_BRANCH),master)
	@curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$(CLOUDFLARE_ZONE_ID)/purge_cache" -H "X-Auth-Email: $(CLOUDFLARE_EMAIL)" -H "X-Auth-Key: $(CLOUDFLARE_API_TOKEN)" -H "Content-Type: application/json" --data '{"purge_everything":true}'
endif
