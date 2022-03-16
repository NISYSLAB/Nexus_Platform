
curr_dir=$( basename "$PWD" )
zip -r ${curr_dir}.zip ./*.sh ./*.slurm
echo "${curr_dir}.zip created"
echo ""

