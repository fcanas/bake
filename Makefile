# Rule for converting github flavored markdown to html5
MARKDOWN := pandoc --from markdown_github --to html5 --standalone

# Deploy directory.
# Excluded from source search. Prepended to all output files
DEPLOY_DIRECTORY = ./deploy/

# Source control directory, also excluded from source search
SRC_CTL = .git

# All markdown files. Recursive search with `find`
ALL_MD = $(shell find . -type f -name '*.md')

# For all known markdown files: change md extension to html and prepend the
# deploy directory.
HTML_FROM_MD := $(patsubst %.md,%.html,$(ALL_MD))

# All html files. Recursive search with `find`
ALL_HTML = $(shell find . -type f -name '*.html')

# All files that should be deployed as-is
ALL_IDENTITY := $(ALL_HTML)
# Strip out anything that's in the deploy directory. We're trying to build
# source files.
NON_DEPLOY_IDENTITY := $(filter-out $(DEPLOY_DIRECTORY)%,$(ALL_IDENTITY))

ALL_TO_DEPLOY = $(NON_DEPLOY_IDENTITY) $(HTML_FROM_MD)
DEPLOY_TARGETS := $(subst ./,$(DEPLOY_DIRECTORY),$(ALL_TO_DEPLOY))

# First recipe is default. Nothing to do except dependency on all html files.
bake: $(DEPLOY_TARGETS)

clean:
	@rm -rf $(DEPLOY_DIRECTORY)

# Recipe for html files in the deploy directory for a corresponding markdown
# file
$(addprefix $(DEPLOY_DIRECTORY),%.html): %.md
	@echo Converting: $<
	@mkdir -p $(dir $@)
	@$(MARKDOWN) $< --output $@

$(addprefix $(DEPLOY_DIRECTORY),%.html): %.html
	@echo All Identity: $(ALL_IDENTITY)
	@echo Non deploy identity: $(NON_DEPLOY_IDENTITY)
	@echo Moving $< to $@
	@mkdir -p $(dir $@)
	@cp $< $@
