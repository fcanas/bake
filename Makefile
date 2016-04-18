MARKDOWN := pandoc --from markdown_github --to html5 --standalone
DEPLOY_DIRECTORY = ./deploy
SRC_CTL = .git
ROOT_DIRECTORY = .
DIRECTORIES = $(shell find $(ROOT_DIRECTORY) -type d | grep -v '$(DEPLOY_DIRECTORY)\|$(SRC_CTL)' | tr '\n' ':')
VPATH = $(DIRECTORIES)
ALL_MD := $(wildcard *.md) $(wildcard **/*.md)
HTML_FROM_MD := $(addprefix $(DEPLOY_DIRECTORY)/,$(patsubst %.md,%.html,$(ALL_MD)))

bake: $(HTML_FROM_MD)

$(addprefix $(DEPLOY_DIRECTORY)/,%.html): %.md
	@echo $<
	@mkdir -p $(dir $@)
	@$(MARKDOWN) $< --output $@
