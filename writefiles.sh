#!/bin/bash

# Scipt for extracting MoinMoin Wiki RST files to a tar-ball

# Define location of MoinMoin Wiki directories:
MOINDIR=/var/moin

if [[ $# -ne 1 ]]
then
	echo "Usage: $0 <wiki-name>"
	echo "Directories in $MOINDIR may include some Wikis:"
	ls -l $MOINDIR
	exit 1
fi

# We need the dos2unix tool to convert CR/LF from MoinMoin files to LF
if [[ ! `which dos2unix` ]]
then
        echo "The dos2unix tool is missing, please install it."
        exit 1
fi


# This is the MoinMoin Wiki pages which we are copying:
WIKI=$1

# Output tar-ball file
TARFILE=/tmp/$WIKI.tar.gz
# We omit these page patterns
OMIT_PATTERNS="HelpOnMacros WikiCourse Building_a_Cluster AdminGroup BadContent Old_ Cluster_software Singularity niflheim6 SystemImager X11_on_Windows"

# Location of MoinMoin page directories
TOPDIR=$MOINDIR/$WIKI/data/pages
TMPDIR=/tmp
RSTDIR=$TMPDIR/$WIKI
echo
echo "Copy MoinMoin Wiki $WIKI RST pages to a temporary directory $RSTDIR"
echo

# Sanity check
if [[ ! -d $TOPDIR ]]
then
	echo "ERROR: $TOPDIR does not exist"
	exit -1
fi

# Make a clean directory
rm -rf $RSTDIR
mkdir -pv $RSTDIR

echo Process directories in $TOPDIR and copy files to $RSTDIR
echo
cd $TOPDIR

for dir in *
do
	# Only process directories
	if [[ ! -d $dir ]]
	then
		continue
	fi
	for pat in $OMIT_PATTERNS
	do
		if [[ $dir == ${pat}* ]]
		then
			continue 2
		fi
	done
	# echo Processing directory $TOPDIR/$dir
	# Munge the Moin directory names with "(2?)" and other patterns
	mungedname=`echo $dir | sed -e '/(2d)/s//-/g' -e '/(2e)/s//./g' -e '/(2f)/s//-/g' -e '/Niflheim7/s//Niflheim/'`
	rev=$dir/revisions
	# Copy the newest revision of the RST file
	if [[ -d $rev ]]
	then
		pushd $rev > /dev/null
		latest=`ls -At | head --lines=1`
		# Copy file with perserved timestamp
		cp --preserve=timestamps $latest $RSTDIR/$mungedname.rst
		# Convert CR/LF from MoinMoin files to LF
		dos2unix $RSTDIR/$mungedname.rst
		echo Copied $rev/$latest to $mungedname.rst
		popd > /dev/null
	fi
	# Copy any attachment files to $attcopydir (top-level or a subfolder)
	att=$dir/attachments
	# attcopydir=$RSTDIR/$mungedname
	attcopydir=$RSTDIR/attachments
	if [[ -d $att ]]
	then
		content="$(ls -A $att)"
		if [[ -n "$content" ]]
		then
			pushd $att > /dev/null
			for file in *
			do
				# Omit large .tar.gz files
				if [[ $file != *.tar.gz ]]
				then
					if [[ ! -d $attcopydir ]]
					then
						mkdir -pv $attcopydir
					fi
					cp --no-clobber --preserve=timestamps $file $attcopydir/
					echo Copied attachment file: $file
				fi
			done
			popd > /dev/null
		fi
	fi
done

echo
echo Writing files to a tar-file:
cd $TMPDIR
tar czf $TARFILE $WIKI
ls -l $TARFILE
# Cleanup:
# rm -rf $RSTDIR
