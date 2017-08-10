"""Tests against the generated json file."""
from helpers import _load_site

ALLOWED_SHORT_SLUGS = [
    '/hello-world/',
    '/reunification/',
]


def test_duplicate_permalinks():
    """Test to see that no entries point to the same url."""
    site = _load_site()
    links = {}
    for entry in site:
        url = site[entry]['url']
        if url in links.keys():
            assert entry == links[url]
        else:
            links[url] = entry


def test_post_slug_word_count():
    """Forbid short urls in blog post to avoid collisions with future pages."""
    site = _load_site()
    for entry in site:
        if site[entry]['content_type'] == 'post':
            slug_words = site[entry]['url'].split('-')
            if len(slug_words) < 3 and site[entry]['url'] not in ALLOWED_SHORT_SLUGS:
                assert entry == "Slug has too few words"
