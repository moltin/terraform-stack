.PHONY: docs
docs: ## terraform docs
	@$(MAKE) pull-extra-docs && \
	\
	bin/docs && \
	\
	rm docs/TODO.md ; rm docs/RESOURCES.md

pull-extra-docs: ## pull extra documentation to be used by the docs task
	@git clone -q git@github.com:moltin/terraform-modules.git tmp && \
	cd tmp && \
	git filter-branch --prune-empty --subdirectory-filter docs -- --all && \
 	git filter-branch -f --prune-empty --index-filter 'git rm -q --cached --ignore-unmatch $$(git ls-files | grep -v "TODO.md\|RESOURCES.md")' && \
 	mv * ../docs && \
	cd .. && \
 	rm -rf tmp
