#!/bin/bash

# Script for converting MoinMoin Wiki RST files to Sphinx format using sphinx-quickstart
# The sphinx-quickstart manual is at https://www.sphinx-doc.org/en/master/man/sphinx-quickstart.html

if [[ $# -ne 1 ]]
then
	echo "Usage: $0 <wiki-name>"
	exit 1
fi

# If you do NOT want to use a Python Virtual Environment, comment out this check:
if [[ -z "$VIRTUAL_ENV" ]]
then
	echo "ERROR: This script is NOT running within a Python Virtual Environment, see README.md"
	exit 1
fi

# This is the MoinMoin Wiki pages which we are copying:
WIKI=$1
TARBALL=$WIKI.tar.gz
SPHINXDIR=${WIKI}-sphinx
# Configure Sphinx template directory to be current directory
# See sphinx-quickstart -h and the manual section "Project templating"
SPHINXTEMPLATE="--templatedir ."

# Check if the $WIKI/ directory was already created
if [[ -d $WIKI ]]
then
	echo Directory $WIKI already exists, not unpacking the tar-ball $TARBALL
elif [[ -s $TARBALL ]]
then
	# Unpack the tar-ball created by writefiles.sh
	# This must create a folder named $WIKI
	echo Unpacking tar-ball file $TARBALL
	ls -l $TARBALL
	tar xzf $TARBALL
	if [[ ! -d $WIKI ]]
	then
		echo ERROR: Directory $WIKI not found
		exit -1
	fi
else
	echo ERROR: Tar-ball file $TARBALL not found
	exit -1
fi

# Initialize the Sphinx directory with sphinx-quickstart
if [[ -d $SPHINXDIR ]]
then
	echo Directory $SPHINXDIR already exists, skipping sphinx-quickstart initialization
else
	if [[ -z "$AUTHOR" ]]
	then
		echo ERROR: Author name variable AUTHOR has not been set
		exit -1
	fi
	echo "Setting project name=$WIKI, language=English, version=1.0, and Author=$AUTHOR"
	export LANGUAGE="en"
	export VERSION="1.0"
	echo Create a Sphinx directory ${SPHINXDIR}
	mkdir -pv ${SPHINXDIR}
	cp moin2sphinx.py ${SPHINXDIR}/
	echo Setup Sphinx with:
	echo sphinx-quickstart --quiet -p "$WIKI" -v $VERSION -a "$AUTHOR" -l $LANGUAGE ${SPHINXTEMPLATE} ${SPHINXDIR}
	sphinx-quickstart --quiet -p "$WIKI" -v $VERSION -a "$AUTHOR" -l $LANGUAGE ${SPHINXTEMPLATE} ${SPHINXDIR}
fi

echo Convert Moin files to Sphinx syntax in directory ${SPHINXDIR}
# Capitalize the first letter:
echo "The project name will be ${WIKI^}"
cd ${SPHINXDIR}
python3 moin2sphinx.py ../${WIKI}/ . ${WIKI^}

echo "Copy all attachments to a new attachments directory"
mkdir -pv attachments
cp --no-clobber --preserve=timestamps ../${WIKI}/attachments/* attachments/

cat <<EOF
Now you can go to ${SPHINXDIR} 
Review and edit the index file index.rst to order lines as you prefer.
Then do a 'make dirhtml' or 'make html'.
The HTML pages will be built in the _build/html/ folder.
EOF
