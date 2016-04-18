# Rule for converting github flavored markdown to html5
MARKDOWN := pandoc --from markdown_github --to html5 --standalone

# Deploy directory.
# Excluded from source search. Prepended to all output files
DEPLOY_DIRECTORY = ./deploy

# Source control directory, also excluded from source search
SRC_CTL = .git

# All directories to look for sources in.
# VPATH tells make to look for sources there.
VPATH = $(shell find . -type d | grep -v '$(DEPLOY_DIRECTORY)\|$(SRC_CTL)' | tr '\n' ':')
# All markdown files
ALL_MD := $(wildcard *.md) $(wildcard **/*.md)
# Take all known markdown files, prepend the deploy directory, and change md
# extension to html. We use this later to tell Make that the `bake` recipe
# depends on these files.
HTML_FROM_MD := $(addprefix $(DEPLOY_DIRECTORY)/,$(patsubst %.md,%.html,$(ALL_MD)))

# First recipe is default. Nothing to do except dependency on all html files.
bake: $(HTML_FROM_MD)

# Recipe for html files in the deploy directory for a corresponding markdown
# file
$(addprefix $(DEPLOY_DIRECTORY)/,%.html): %.md
	@echo $<
	@mkdir -p $(dir $@)
	@$(MARKDOWN) $< --output $@
