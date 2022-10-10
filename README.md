# Moin2Sphinx
Migration of a MoinMoin v1.x RST-based Wiki to Sphinx
-----------------------------------------------------

This repository describes a method for migrating an existing Wiki site,
implemented as a [MoinMoin][1] Wiki engine version 1.9.x (which is based on Python2) 
to the [Sphinx][2] documentation generator.

It is assumed that the [MoinMoin][1] v1.9.x Wiki content is using [Restructured Text][3] (RST) files.
Other file formats are also possible, but are not considered here.

[1]: https://moinmo.in/
[2]: https://www.sphinx-doc.org/en/master/
[3]: https://docutils.sourceforge.io/rst.html

Add information to MoinMoin pages
---------------------------------

While the [sphinx-quickstart][5] tool can parse most [MoinMoin][1] pages, there are some cases where we have to insert 
extra information to some MoinMoin RST pages:

* Cross-page links to section headings in other pages need to have a *custom anchor* inserted above the section heading,
  for example:
```
.. _rst-overview:

RST Overview
============
```
NOTE: This is *only* required for sections that are linked to, and *not* for all sections!

In this way a reference to ```rst-overview``` can be made from any page using both [MoinMoin][1] as well as [Sphinx][2].
See [Use a custom anchor](https://sublime-and-sphinx-guide.readthedocs.io/en/latest/references.html#use-a-custom-anchor) for a description.

Extract RST files from MoinMoin
-------------------------------

[MoinMoin][1] stores its Wikis in a top-level directory, and we assume here that the /var/moin directory is used.
The [writefiles.sh](writefiles.sh) script should be edited for the needs of your Wiki:

* First you must edit the script to omit these page patterns and add other pages/patterns that you do not want to convert:
```
OMIT_PATTERNS="HelpOnMacros WikiCourse AdminGroup BadContent "
```

* Also, some [MoinMoin][1] directories have separators such as (2d), (2e) of (2f), and these are rewritten in the script.
  Look for the ```mungedname=``` line and add any additional rewritings as needed for your Wiki.

Now execute the [writefiles.sh](writefiles.sh) script on the server where /var/moin is located:
```
Moin-server$ writefiles.sh <wikiname>
```
where the ```<wikiname>``` is one of the Wikis in /var/moin.

The [writefiles.sh](writefiles.sh) script generates a tar-ball of the newest files in /var/moin/```<wikiname>```/data/pages/.
It will ignore all older files (previous page revisions).
Since there does not seem to be any way to detect whether a file is in RST format or some other format,
we simply copy the files and append an ```.rst``` extension.

Setup a Python3 virtual environment
-----------------------------------

We will use a [Python3 virtual environment][4] to process RST files from [MoinMoin][1]:

```
python3 -m venv venv
```

Activate it and install [Sphinx][2] :

```
. venv/bin/activate
pip install --upgrade pip
pip install sphinx
```

[4]: https://docs.python.org/3/library/venv.html

Convert the RST files into Sphinx format
----------------------------------------

Copy the tar-ball generated above to the current directory.

Run the script [moin2sphinx.sh](moin2sphinx.sh) on ```<wikiname>``` with some predefined author names:
```
export AUTHOR="Fullname1[,Fullname2...]"
./moin2sphinx.sh <wikiname>
```
Here you may also add the E-mail address to the author name.

This script will perform these steps:

* Unpack the tar-ball files to a subfolder ```<wikiname>```

* Create [Sphinx][2] files in a subfolder named ```<wikiname>```-sphinx.

* Call the [sphinx-quickstart][5] tool to initialize the project.
  We are going to set the [Sphinx][2] *Project name* to ```<wikiname>``` (with first letter capitalized), and the version to 1.0.

* Run the script [moin2sphinx.py](moin2sphinx.py) to convert the RST files in subfolder ```<wikiname>``` to [Sphinx][2] format
  into the folder ```<wikiname>```-sphinx.

[5]: https://www.sphinx-doc.org/en/master/man/sphinx-quickstart.html

Edit the table of contents
--------------------------

Go to the ```<wikiname>```-sphinx folder and edit the file ```index.rst```:

* Delete any page names which you do not want in the [Sphinx][2] documentation.

* Reorder page names in a logical way for the project. 

Generate HTML pages
-------------------

Go to the ```<wikiname>```-sphinx folder and run:
```
make html
```
The HTML pages will be built in the _build/html/ subfolder with an index.html file which you can use in a browser, for example:

```
firefox file://<path-to-project>/```<wikiname>```-sphinx/_build/html/index.html
```

To start over the HTML page generation:
```
rm -f _build
make html
```
You can also delete the ```<wikiname>```-sphinx folder and repeat the [moin2sphinx.sh](moin2sphinx.sh) script starting as above.
