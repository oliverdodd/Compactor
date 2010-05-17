# compress
#
# compress a file with yuicompressor
#
# usage: compress [-t type] file

# check for yui compressor -----------------------------------------------------
yuipath="./yuicompressor-2.4.2.jar"
if ! test -f $yuipath
then
	echo "cannot find $yuipath"
	exit
fi
# get options ------------------------------------------------------------------
type="js"
while getopts 't:' OPTION
do
	case $OPTION in
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
	echo "no output file specified"
	exit
fi
ofile=$*
# compress ---------------------------------------------------------------------
# echo "running java -jar $yuipath --type $type -o $ofile $ofile"
java -jar $yuipath --type $type -o "$ofile" "$ofile"