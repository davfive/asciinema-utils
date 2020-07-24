echo "Running bashrc.asciinema.sh ..."

# asciinema.org - terminal recording softare for making videos
#  brew install asciinema 
#  asciinema.org - terminal recording software for video presentations
alias asciirec='asciinema rec -i 2 -c "/bin/bash -l"'

# Using ':' as a prefix for help documentation for asciinema tutorials

asciiscript=""
asciisegment=0

alias="asciinema rec -i 2 -c '/bin/bash -l' $@"

function asciiusage() {
	for error in "$@"; do
		echo "Error: $error"
		echo
	done
	echo "Usage: asciirec [-t <title>]"
	echo "       asciistart <asciiscript file>"
	echo "       : # yes, just a colon. To show the next segment"

	[ $# -gt 0 ] && return 1 || return 0
}

function asciistart() {
	if [[ $# -ne 1 || ! -f "$1" ]]; then
		asciiusage "Expecting an asciiscript file. Got $1"
		return 1
	fi
	asciiscript=$1
	asciisegment=0

	echo "*** ASCIINEMA RECORDING STARTS HERE ***"
	return 0
}
# asciistop is actually just 'exit' because asciirec requires that

# Go to next segment (change : to whatever you want, I like :)
function next() {
	local currseg numseglines
	if [[ -z "$asciiscript" || ! -f "$asciiscript" ]]; then
		asciiusage "No asciiscript set."
		return 1
	fi

	currseg=0
	numseglines=0
	while IFS='' read -r line || [ -n "$line" ]
	do
		[ $? -ne 0 ] && sawEOF=true

		[ "$currseg" -gt "$asciisegment" ] && break;

		# : as a line by itself is the segment delimeter
		if [ "x$line" == "x:" ]; then
			(( ++currseg ))
			continue	
		fi

		if [ "$currseg" -eq "$asciisegment" ]; then
			(( ++numseglines ))
			echo "$line"
		fi
	done < $asciiscript

	if [ "$numseglines" -eq 0 ]; then
		echo "*** ASCIINEMA RECORDING ENDS HERE ***"
		echo "Type exit to end recording. Then Ctrl-c to save"
	fi
	(( ++asciisegment ))
	return 0
}
