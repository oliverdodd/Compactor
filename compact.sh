# compact
#
# combine files and then compress the result with yuicompressor
#
# usage: compact [-o outfile] [-t type] files

# check for yui compressor -----------------------------------------------------
yuipath="./yuicompressor-2.4.2.jar"
if ! test -f $yuipath
then
	echo "cannot find $yuipath"
	exit
fi
# get options ------------------------------------------------------------------
type="js"
while getopts 'o:t:' OPTION
do
	case $OPTION in
	o)	ofile="$OPTARG"
		;;
	t)	type="$OPTARG"
		;;
	?)	printf "Usage: %s: [-o outfile] [-t type] files\n" $(basename $0) >&2
		exit 2
		;;
	esac
done
shift $(($OPTIND - 1))
# get files --------------------------------------------------------------------
if (( $# < 1 ))
then
	echo "no files specified"
	exit
fi
files=$*
# combine files ----------------------------------------------------------------
# echo "combining files"
cat $files > $ofile
# compress results -------------------------------------------------------------
# echo "running java -jar $yuipath --type $type -o $ofile $ofile"
java -jar $yuipath --type $type -o "$ofile" "$ofile"