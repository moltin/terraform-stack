.PHONY: docs
docs: ## terraform docs
	@$(MAKE) pull-extra-docs && \
	\
	bin/docs && \
	\
	rm docs/TODO.md ; rm docs/RESOURCES.md \
  \
  $(MAKE) changelog

.PHONY: changelog
changelog: ## generate changelog
	@docker run --rm -it -v $$(pwd):/code moltin/gitchangelog > CHANGELOG.md

pull-extra-docs: ## pull extra documentation to be used by the docs task, see http://stackoverflow.com/a/3212697/1012369
	@git clone -q git@github.com:moltin/terraform-modules.git tmp && \
	cd tmp && \
	git filter-branch -f --prune-empty --subdirectory-filter docs --index-filter 'git rm -q --cached --ignore-unmatch $$(git ls-files | grep -v "TODO.md\|RESOURCES.md")' && \
 	mv * ../docs && \
	cd .. && \
 	rm -rf tmp
