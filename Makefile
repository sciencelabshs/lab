# See the README for installation instructions.

# Utilities
JS_COMPILER = ./node_modules/uglify-js/bin/uglifyjs -c warnings=false -m -
MARKDOWN_COMPILER = kramdown

# Turns out that just pointing Vows at a directory doesn't work, and its test matcher matches on
# the test's title, not its pathname. So we need to find everything in test/vows first.
VOWS = find test/vows -type f -name '*.js' -o -name '*.coffee' ! -name '.*' | xargs ./node_modules/.bin/vows --isolate --dot-matrix
MOCHA = find test/mocha -type f -name '*.js' -o -name '*.coffee' ! -name '.*' | xargs node_modules/.bin/mocha --reporter dot

SASS_COMPILER = sass -I src -I public
R_OPTIMIZER = ./node_modules/.bin/r.js -o

LAB_SRC_FILES := $(shell find src/lab -type f ! -name '.*' -print)
MD2D_SRC_FILES := $(shell find src/lab/models/md2d -type f ! -name '.*' -print)

GRAPHER_SRC_FILES := $(shell find src/lab/grapher -type f ! -name '.*' -print)
IMPORT_EXPORT_SRC_FILES := $(shell find src/lab/import-export -type f ! -name '.*' -print)
MML_CONVERTER_SRC_FILES := $(shell find src/lab/mml-converter -type f ! -name '.*' -print)

COMMON_SRC_FILES := $(shell find src/lab/common -type f ! -name '.*' -print)

# files generated by script during build process so cannot be listed using shell find.
COMMON_SRC_FILES += src/lab/lab.version.js

FONT_FOLDERS := $(shell find vendor/fonts -mindepth 1 -maxdepth 1)

SASS_LAB_LIBRARY_FILES := $(shell find src/sass/lab -name '*.sass')

# targets

INTERACTIVE_FILES := $(shell find src/models src/interactives -name '*.json' -exec echo {} \; | sed s'/src\/\(.*\)/public\/\1/' )
vpath %.json src

HAML_FILES := $(shell find src -name '*.haml' -exec echo {} \; | sed s'/src\/\(.*\)\.haml/public\/\1/' )
vpath %.haml src

SASS_FILES := $(shell find src -name '*.sass' -and -not -path "src/sass/*" -exec echo {} \; | sed s'/src\/\(.*\)\.sass/public\/\1.css/' )
SASS_FILES += $(shell find src -name '*.scss' -and -not -path "src/sass/*" -exec echo {} \; | sed s'/src\/\(.*\)\.scss/public\/\1.css/' )
vpath %.sass src
vpath %.scss src

LAB_JS_FILES = \
	public/lab/lab.js \
	public/lab/lab.grapher.js \
	public/lab/lab.mml-converter.js \
	public/lab/lab.import-export.js

# default target executed when running make. Run the $(MAKE) public task rather than simply
# declaring a dependency on 'public' because 'bundle install' and 'npm install' might update some
# sources, and we want to recompute stale dependencies after that.
.PHONY: all
all: \
	vendor/d3/d3.js \
	node_modules
	$(MAKE) public

# clean, make ...
.PHONY: everything
everything:
	$(MAKE) clean
	$(MAKE) all

.PHONY: src
src: \
	public/license.html \
	$(LAB_JS_FILES) \
	$(LAB_JS_FILES:.js=.min.js) \
	$(HAML_FILES) \
	$(SASS_FILES) \
	$(INTERACTIVE_FILES) \
	public/embeddable.html \
	public/lab/lab.json

.PHONY: clean
clean:
	ruby script/check-development-dependencies.rb
	bundle install
	mkdir -p public
	$(MAKE) clean-public
	rm -f src/lab/lab.version.js
	# Remove Node modules.
	rm -rf node_modules
	$(MAKE) prepare-submodules

# public dir cleanup.
.PHONY: clean-public
clean-public:
	bash -O extglob -c 'rm -rf public/!(.git|version)'

# versioned archives cleanup.
.PHONY: clean-archives
clean-archives:
	rm -rf version
	rm -rf public/version

.PHONY: prepare-submodules
prepare-submodules:
	-$(MAKE) submodule-update || $(MAKE) submodule-update-tags

# ------------------------------------------------
#
#   Testing
#
# ------------------------------------------------

.PHONY: test
test: test/layout.html \
    node_modules/d3 \
    node_modules/arrays \
	public \
	$(LAB_JS_FILES) \
	$(JS_FILES:.js=.min.js)
	@echo
	@echo 'Mocha tests ...'
	@$(MOCHA)
	@echo 'Vows tests ...'
	@$(VOWS)
	@echo

# run vows test WITHOUT trying to build Lab JS first. Run 'make; make test-mocha' to build & test.
.PHONY: test-vows
test-vows:
	@echo 'Running Vows tests ...'
	@$(VOWS)

# run mocha test WITHOUT trying to build Lab JS first. Run 'make; make test-mocha' to build & test.
.PHONY: test-mocha
test-mocha:
	@echo 'Running Mocha tests ...'
	@$(MOCHA)

.PHONY: debug-mocha
debug-mocha:
	@echo 'Running Mocha tests in debug mode...'
	@$(MOCHA) --debug-brk

%.min.js: %.js
	@rm -f $@
ifndef LAB_DEVELOPMENT
	$(JS_COMPILER) < $< > $@
	@chmod ug+w $@
else
endif

.PHONY: public/test
public/test: public/embeddable-test-mocha.html
	mkdir -p public/test
	cp node_modules/mocha/mocha.js public/test
	cp node_modules/mocha/mocha.css public/test
	cp node_modules/chai/chai.js public/test
	cp test/test1.js public/test
	./node_modules/mocha-phantomjs/bin/mocha-phantomjs -R dot 'public/embeddable-test-mocha.html#interactives/samples/1-oil-and-water-shake.json'

# ------------------------------------------------
#
#   Submodules
#
# ------------------------------------------------

vendor/d3:
	submodule-update

.PHONY: submodule-update
submodule-update:
	git submodule update --init --recursive

.PHONY: submodule-update-tags
submodule-update-tags:
	git submodule sync
	git submodule foreach --recursive 'git fetch --tags'
	git submodule update --init --recursive

# ------------------------------------------------
#
#   Node modules
#
# ------------------------------------------------

node_modules: node_modules/d3 \
	node_modules/arrays
	npm install

node_modules/d3:
	npm install vendor/d3

node_modules/arrays:
	npm install src/modules/arrays

# ------------------------------------------------
#
#   public/
#
# ------------------------------------------------
.PHONY: public
public: \
	copy-resources-to-public \
	public/lab \
	public/lab/jars/lab-sensor-applet-interface-dist \
	public/vendor \
	src

# copy everything (including symbolic links) except files that are
# used to generate resources from src/ to public/
.PHONY: copy-resources-to-public
copy-resources-to-public:
	rsync -aq --exclude='helpers/' --exclude='layouts/' --exclude='modules/' --exclude='sass/' --exclude='vendor/' --exclude='lab/' --filter '+ */' --exclude='*.haml' --exclude='*.sass' --exclude='*.scss' --exclude='*.yaml' --exclude='*.coffee' --exclude='*.rb' --exclude='*.md' src/ public/
	mkdir -p public/lab/resources
	rsync -aq src/lab/resources/ public/lab/resources/

# ------------------------------------------------
#
#   public/lab
#
#   Generates the Lab Framework JavaScript resources
#
# ------------------------------------------------

public/lab:
	mkdir -p public/lab

public/lab/lab.json: \
	src/lab/common/controllers/interactive-metadata.js \
	src/lab/models/energy2d/metadata.js \
	src/lab/models/md2d/models/metadata.js \
	src/lab/models/sensor/metadata.js \
	src/lab/models/signal-generator/metadata.js \
	src/lab/models/iframe/metadata.js \
	src/lab/models/solar-system/models/metadata.js
	node src/helpers/lab.json.js

public/lab/lab.js: \
	$(LAB_SRC_FILES) \
	src/lab/lab.version.js
	$(R_OPTIMIZER) src/lab/lab.build.js logLevel=2

src/lab/lab.version.js: \
	script/generate-js-version.rb \
	.git/HEAD \
	.git/refs/*
	./script/generate-js-version.rb

public/lab/lab.grapher.js: \
	$(GRAPHER_SRC_FILES) \
	$(COMMON_SRC_FILES)
	$(R_OPTIMIZER) src/lab/grapher/grapher.build.js logLevel=2

public/lab/lab.import-export.js: \
	$(IMPORT_EXPORT_SRC_FILES) \
	$(COMMON_SRC_FILES)
	$(R_OPTIMIZER) src/lab/import-export/import-export.build.js logLevel=2

public/lab/lab.mml-converter.js: \
	$(MML_CONVERTER_SRC_FILES) \
	$(LAB_SRC_FILES) \
	$(COMMON_SRC_FILES)
	$(R_OPTIMIZER) src/lab/mml-converter/mml-converter.build.js logLevel=2

public/lab/jars:
	mkdir -p public/lab/jars

public/lab/jars/lab-sensor-applet-interface-dist: \
	vendor/lab-sensor-applet-interface-dist \
	public/lab/jars
	cp -R vendor/lab-sensor-applet-interface-dist/jars public/lab/jars/lab-sensor-applet-interface-dist

# ------------------------------------------------
#
#   public/vendor
#
# External frameworks are built from git submodules checked out into vendor/.
# Just the generated libraries and licenses are copied to public/vendor
#
# ------------------------------------------------

public/vendor: \
	public/vendor/d3 \
	public/vendor/jquery/jquery.min.js \
	public/vendor/jquery-ui/jquery-ui.min.js \
	public/vendor/jquery-ui-touch-punch/jquery.ui.touch-punch.min.js \
	public/vendor/jquery-selectBoxIt/jquery.selectBoxIt.min.js \
	public/vendor/tinysort/jquery.tinysort.js \
	public/vendor/jquery-context-menu \
	public/vendor/fonts \
	public/favicon.ico

public/vendor/d3: vendor/d3
	mkdir -p public/vendor/d3
	cp vendor/d3/d3*.js public/vendor/d3
	cp vendor/d3/LICENSE public/vendor/d3/LICENSE
	cp vendor/d3/README.md public/vendor/d3/README.md

public/vendor/jquery-ui-touch-punch/jquery.ui.touch-punch.min.js: \
	public/vendor/jquery-ui-touch-punch \
	vendor/jquery-ui-touch-punch/jquery.ui.touch-punch.min.js \
	vendor/jquery-ui-touch-punch/jquery.ui.touch-punch.js
	cp vendor/jquery-ui-touch-punch/jquery.ui.touch-punch.min.js public/vendor/jquery-ui-touch-punch
	cp vendor/jquery-ui-touch-punch/jquery.ui.touch-punch.js public/vendor/jquery-ui-touch-punch

public/vendor/jquery-ui-touch-punch:
	mkdir -p public/vendor/jquery-ui-touch-punch

public/vendor/jquery-selectBoxIt/jquery.selectBoxIt.min.js: \
	vendor/jquery-selectBoxIt/src/javascripts/jquery.selectBoxIt.js \
	vendor/jquery-selectBoxIt/src/javascripts/jquery.selectBoxIt.min.js \
	vendor/jquery-selectBoxIt/src/stylesheets/jquery.selectBoxIt.css \
	public/vendor/jquery-selectBoxIt
	cp vendor/jquery-selectBoxIt/src/javascripts/jquery.selectBoxIt.js public/vendor/jquery-selectBoxIt
	cp vendor/jquery-selectBoxIt/src/javascripts/jquery.selectBoxIt.min.js public/vendor/jquery-selectBoxIt
	cp vendor/jquery-selectBoxIt/src/stylesheets/jquery.selectBoxIt.css public/vendor/jquery-selectBoxIt

public/vendor/jquery-selectBoxIt:
	mkdir -p public/vendor/jquery-selectBoxIt

public/vendor/jquery-context-menu:
	mkdir -p public/vendor/jquery-context-menu
	cp vendor/jquery-context-menu/src/jquery.contextMenu.js public/vendor/jquery-context-menu
	cp vendor/jquery-context-menu/src/jquery.contextMenu.css public/vendor/jquery-context-menu

public/vendor/jquery/jquery.min.js: \
	vendor/jquery \
	public/vendor/jquery
	cp vendor/jquery/jquery.js public/vendor/jquery
	cp vendor/jquery/jquery.min.js public/vendor/jquery
	cp vendor/jquery/jquery.min.map public/vendor/jquery
	cp vendor/jquery/MIT-LICENSE.txt public/vendor/jquery

public/vendor/jquery:
	mkdir -p public/vendor/jquery

public/vendor/jquery-ui/jquery-ui.min.js: \
	vendor/components-jqueryui \
	public/vendor/jquery-ui
	cp vendor/components-jqueryui/MIT-LICENSE.txt public/vendor/jquery-ui
	mkdir -p public/vendor/jquery-ui/i18n
	cp vendor/components-jqueryui/ui/jquery-ui.js public/vendor/jquery-ui
	cp vendor/components-jqueryui/ui/i18n/jquery-ui-i18n.js public/vendor/jquery-ui/i18n
	cp vendor/components-jqueryui/ui/minified/jquery-ui.min.js public/vendor/jquery-ui
	cp vendor/components-jqueryui/ui/minified/i18n/jquery-ui-i18n.min.js public/vendor/jquery-ui/i18n
	cp vendor/components-jqueryui/themes/base/jquery-ui.css public/vendor/jquery-ui
	cp vendor/components-jqueryui/themes/base/minified/jquery-ui.min.css public/vendor/jquery-ui
	cp -r vendor/components-jqueryui/themes/base/images public/vendor/jquery-ui

public/vendor/jquery-ui:
	mkdir -p public/vendor/jquery-ui

public/vendor/tinysort:
	mkdir -p public/vendor/tinysort

public/vendor/tinysort/jquery.tinysort.js: \
	public/vendor/tinysort
	cp -r vendor/tinysort/src/* public/vendor/tinysort
	cp vendor/tinysort/README.md public/vendor/tinysort

public/vendor/sizzle:
	mkdir -p public/vendor/sizzle
	cp vendor/sizzle/sizzle.js public/vendor/sizzle
	cp vendor/sizzle/LICENSE public/vendor/sizzle
	cp vendor/sizzle/README public/vendor/sizzle

public/vendor/fonts: $(FONT_FOLDERS)
	mkdir -p public/vendor/fonts
	cp -R vendor/fonts public/vendor/
	rm -rf public/vendor/fonts/Font-Awesome/.git*
	rm -f public/vendor/fonts/Font-Awesome/.gitignore
	rm -rf public/vendor/fonts/Font-Awesome/less
	rm -rf public/vendor/fonts/Font-Awesome/sass

public/favicon.ico:
	cp -f src/favicon.ico public/favicon.ico

vendor/jquery:
	git submodule update

vendor/components-jqueryui:
	git submodule update

vendor/lab-sensor-applet-interface-dist:
	git submodule update --init --recursive

vendor/sensor-labquest-2-interface/dist/sensor-labquest-2-interface.js:
	git submodule update --init --recursive

vendor/sensor-server-interface/dist/sensor-server-interface.js:
	git submodule update --init --recursive

# ------------------------------------------------
#
#   targets for generating html, js, and css resources
#
# ------------------------------------------------

test/%.html: test/%.html.haml
	haml $< $@

public/%.html: src/%.html.haml script/setup.rb
	haml -r ./script/setup.rb -r ./src/helpers/font-cdn.rb $< $@

public/%.html: src/%.html
	cp $< $@

public/%.css: src/%.css
	cp $< $@

public/grapher.css: src/grapher.sass \
	src/sass/lab/_colors.sass \
	src/sass/lab/_bar_graph.sass \
	src/sass/lab/_graphs.sass \
	public/lab-grapher.scss
	$(SASS_COMPILER) src/grapher.sass public/grapher.css

public/%.css: %.scss
	$(SASS_COMPILER) $< $@

public/lab-grapher.scss:
	cp vendor/lab-grapher/css/lab-grapher.css public/lab-grapher.scss

public/%.css: %.sass $(SASS_LAB_LIBRARY_FILES) \
	public/lab-grapher.scss
	@echo $($<)
	$(SASS_COMPILER) $< $@

public/%.html: %.md
	@rm -f $@
	$(MARKDOWN_COMPILER) $< --template src/layouts/kramdown.html.erb > $@

public/interactives/%.json: src/interactives/%.json
	@cp $< $@

public/models/%.json: src/models/%.json
	@cp $< $@

# delete the .md.static files and don't bother creating them if they don't need to be
.INTERMEDIATE: %.md.static

# ------------------------------------------------
#
#   Targets to help debugging/development of Makefile
#
# ------------------------------------------------

.PHONY: h
h:
	@echo $(HAML_FILES)

.PHONY: s
s:
	@echo $(SASS_FILES)

.PHONY: s1
sl:
	@echo $(SASS_LAB_LIBRARY_FILES)

.PHONY: cm
cm:
	@echo $(COMMON_SRC_FILES)

.PHONY: md2
md2:
	@echo $(MD2D_SRC_FILES)

.PHONY: gr
gr:
	@echo $(GRAPHER_SRC_FILES)

.PHONY: int
int:
	@echo $(INTERACTIVE_FILES)

.PHONY: sources
sources:
	@echo $(LAB_SRC_FILES)
