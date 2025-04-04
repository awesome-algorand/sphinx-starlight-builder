# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINX_OPTS      ?=
SPHINX_BUILD     ?= sphinx-build
DIFFTOOL         ?= meld
TESTS_DIR         = tests
SOURCE_DIR        = $(TESTS_DIR)/source
BUILD_DIR         = $(TESTS_DIR)/docs-build
EXPECTED_DIR      = $(TESTS_DIR)/expected

.PHONY: help clean test test-diff diff meld release

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINX_BUILD) -M help "$(SOURCE_DIR)" "$(BUILD_DIR)" $(SPHINX_OPTS) $(O)


clean:
	rm -rf "$(BUILD_DIR)" "$(SOURCE_DIR)/library"


# Catch-all target: route all unknown targets to Sphinx using the new "make mode" option.
# $(O) is meant as a shortcut for $(SPHINX_OPTS).
doc-%:
	@$(SPHINX_BUILD) -M $* "$(SOURCE_DIR)" "$(BUILD_DIR)" $(SPHINX_OPTS) $(O) -a -t Partners


docs: doc-markdown


test-diff:
	@echo "Building markdown..."
	@$(SPHINX_BUILD) -M markdown "$(SOURCE_DIR)" "$(BUILD_DIR)" $(SPHINX_OPTS) $(O) -a -t Partners

	@echo "Building markdown with configuration overrides..."
	@$(SPHINX_BUILD) -M markdown "$(SOURCE_DIR)" "$(BUILD_DIR)/overrides" $(SPHINX_OPTS) $(O) -a \
			-D starlight_http_base="https://localhost" -D starlight_uri_doc_suffix=".html" \
			-D starlight_docinfo=True -D starlight_anchor_sections=True -D starlight_anchor_signatures=True \
			-D autodoc_typehints=signature

	@# Copy just the files for verification
	@cp "$(BUILD_DIR)/overrides/markdown/auto-summery.md" "$(BUILD_DIR)/markdown/overrides-auto-summery.md"
	@cp "$(BUILD_DIR)/overrides/markdown/auto-module.md" "$(BUILD_DIR)/markdown/overrides-auto-module.md"

	@echo "Verifies outputs..."
	@diff --recursive --color=always --side-by-side --text --suppress-common-lines \
			"$(BUILD_DIR)/markdown" "$(EXPECTED_DIR)"


test: test-diff
	@echo "Unit testing and coverage report..."
	@pytest --cov=sphinx_starlight_builder


diff:
	$(DIFFTOOL) "$(BUILD_DIR)/markdown" "$(EXPECTED_DIR)" &


lint:
	@echo "Validate coding conventions with black"
	black sphinx_starlight_builder --check --diff
	@echo "Lint with flake8"
	flake8 . --count --select=E,F,W,C --show-source \
			--max-complexity=10 --max-line-length=120 --statistics \
			--exclude "venv*,.venv,.git"
	@ echo "Lint with pylint"
	pylint sphinx_starlight_builder --disable C0116,C0115


release:
	@rm -rf dist/*
	python3 -m build || exit
	python3 -m twine upload --repository sphinx-starlight-builder dist/*
