

function show() {
	local cmd=$1
	echo "- - - - - - - - - - - - - $cmd - - - - - - - - - - - - - - - -"
    	$cmd
	echo ""
}
show sinfo
show squeue
show sacct
echo 'scontrol show partition'
echo "scontrol show node poc-compute-1-0"

