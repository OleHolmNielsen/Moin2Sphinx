import re
import sys
from pathlib import Path


def normalize(name: str) -> str:
    name = name.replace('(2d)', '-')
    name = name.replace('(2e)', '.')
    name = name.replace('(2f)', '/')
    return name


def fix(name: str) -> str:
    return name.replace('_-_', '_').replace('/', '_')
    # return name.lower().replace('_-_', '_').replace('/', '_')


def m1(match) -> str:
    ref = fix(match[1])
    return f':ref:`{ref}`{match[2]}'


def m2(match) -> str:
    ref = fix(match[2])
    return f':ref:`{match[1]} <{ref}>`'


def fix_links(text, links):
    for link in links:
        text = re.sub(fr'({link})_(\W)', m1, text)
        text = re.sub(fr'`(.*) <({link})>`_', m2, text)
    return text


def add_title(text, rst):
    for line in text.splitlines()[:3]:
        if line.startswith(('===', '---')):
            return text
    title = rst.stem.replace('_', '_')
    title = title[0].upper() + title[1:]
    return f'{title}\n{"=" * len(title)}\n\n' + text


def convert(moin: Path, sphinx: Path):
    pages = []
    links = {}
    # Convert RST files
    for p in moin.glob('*.rst'):
        name = normalize(p.stem)
        links[name] = p
        rst = sphinx / (fix(name) + '.rst')
        text = p.read_text()
        pages.append((rst, text))

    # Fix links in RST pages
    for rst, text in pages:
        text = add_title(text, rst)
        name=rst.stem
        text = f'.. _{name}:\n\n' + fix_links(text, links)
        rst.write_text(text)

    # Create an index.rst main page
    text = f"Welcome to the {wikiname} documentation"
    l = len(text)
    text += "\n"
    text += "=" * l
    text += """

.. toctree::
   :maxdepth: 2
   :caption: Contents:

"""
    text += ('   ' +
            '\n   '.join(f'{rst.stem}'
                         for rst, _ in sorted(pages)) +
            '\n')
    index = sphinx / 'index.rst'
    index.write_text(text)

if __name__ == '__main__':
    moin = Path(sys.argv[1])
    sphinx = Path(sys.argv[2])
    wikiname = sys.argv[3]
    convert(moin, sphinx)
