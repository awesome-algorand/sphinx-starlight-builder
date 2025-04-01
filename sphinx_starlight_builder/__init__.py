"""
A Sphinx extension to add markdown generation support.
"""

from sphinx_starlight_builder.builder import MarkdownBuilder

__version__ = "0.6.7"
__docformat__ = "reStructuredText"


def setup(app):
    app.add_builder(MarkdownBuilder)
    app.add_config_value("starlight_http_base", "", False)
    app.add_config_value("starlight_uri_doc_suffix", "", False)
    app.add_config_value("starlight_anchor_sections", False, False)
    app.add_config_value("starlight_anchor_signatures", False, False)
    app.add_config_value("starlight_docinfo", False, False)
