# Bake

A static site generator that's just [Pandoc](http://pandoc.org) and [Make](https://www.gnu.org/software/make/).

Bake isn't a CMS, or a blog engine. It lets you publish a static site written in markdown, or manual html, or whatever.

The `Makefile` is the relevant code. The rest of the repository is a description of [this site](http://fcanas.github.io/bake) whose correct generation is evidence of Bake working. A mechanism for automated testing of the product isn't planned, but definitely possible.

## Use

Use these instructions to deploy a site with [GitHub pages](https://pages.github.com/).

Create a git repository for your content, and copy the `Makefile` from Bake.

```bash
git init
curl https://raw.githubusercontent.com/fcanas/bake/master/Makefile > Makefile
```

Build the site to see locally:

```bash
make
```

or build the site and deploy to GitHub pages.

```bash
make deploy
```

The Makefile has a `deploy` recipe to push a git subtree to GitHub pages if your remote is setup as `github`. You can edit that area of the Makefile if that doesn't match your configuration.

### Dependencies

Have [Make](https://www.gnu.org/software/make/) on your system.

Install [Pandoc](http://pandoc.org)

See [Pandoc's installation instructions](http://pandoc.org/installing.html) or try

```bash
brew install pandoc
```

## Bake Source

```makefile
# Rule for converting github flavored markdown to html5
MARKDOWN := pandoc --template template.tmp -c writ.min.css --from markdown_github --to html5 --standalone


DEPLOY = deploy
# Deploy directory.
# Excluded from source search. Prepended to all output files
DEPLOY_DIRECTORY = ./$(DEPLOY)/

# Source control directory, also excluded from source search
SRC_CTL = .git

find_all = $(shell find . -type f -name $(1))

# All markdown files. Recursive search with `find`
ALL_MD = $(call find_all,'*.md')
# $(shell find . -type f -name '*.md')

# For all known markdown files: change md extension to html and prepend the
# deploy directory.
HTML_FROM_MD := $(patsubst %.md,%.html,$(ALL_MD))

# Map a function that takes two arguments
map = $(foreach a,$(3),$(call $(1),$(2),$(a)))
PROCESS_TYPES = %.md

### Identity Files
# All files that should be deployed as-is
# Start assuming all files
ALL = $(call find_all,'*.*')
# Non-identity types are types we want to process
# anything in the deploy directory
# and files we want to ignore:
EXCLUDE_TYPES = $(PROCESS_TYPES) $(DEPLOY_DIRECTORY)% ./%.DS_Store ./.git% %.tmp

# filter out types
ALL_IDENTITY := $(call map,filter-out,$(EXCLUDE_TYPES),$(ALL))

# Everything that needs deploying :
# all the identity files
# and all the html files derived from markdown
ALL_TO_DEPLOY = $(ALL_IDENTITY) $(HTML_FROM_MD)
DEPLOY_TARGETS := $(subst ./,$(DEPLOY_DIRECTORY),$(ALL_TO_DEPLOY))

# First recipe is default. Nothing to do except dependency on all html files.
bake: $(DEPLOY_TARGETS)

clean:
	@rm -rf $(DEPLOY_DIRECTORY)

# Recipe for html files in the deploy directory for a corresponding markdown
# file
$(addprefix $(DEPLOY_DIRECTORY),%.html): %.md template.tmp writ.min.css
	@echo Converting: $<
	@mkdir -p $(dir $@)
	@$(MARKDOWN) $< --output $@

$(addprefix $(DEPLOY_DIRECTORY),%.html): %.html
	@echo Moving $< to $@
	@mkdir -p $(dir $@)
	@cp $< $@

$(addprefix $(DEPLOY_DIRECTORY),%.css): %.css
	@echo Moving $< to $@
	@mkdir -p $(dir $@)
	@cp $< $@

REMOTE = github
BRANCH = gh-pages

deploy: undeploy bake
	git add $(DEPLOY)
	git commit -m 'Deploy'
	git subtree push --prefix=$(DEPLOY) $(REMOTE) $(BRANCH)

undeploy:
	git push $(REMOTE) `git subtree split --prefix $(DEPLOY) $(BRANCH)`:$(BRANCH) --force
```
