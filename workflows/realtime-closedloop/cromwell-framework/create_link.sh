
function softlink() {
    local link=$1
    local src=$2
    echo "rm ${link}}"
    rm ${link}

    echo "ln -s ${src} ${link}"
    ln -s "${src}" "${link}"
}

link=cromwell-executions
src=/labs/sharmalab/cloudypipelines/cromwell/${link}
softlink "${link}" "${src}"

sleep 2
link=postgres-synergy1
src=/labs/sharmalab/cloudypipelines/cromwell/database-volume/postgres/synergy1
softlink "${link}" "${src}"

ls -alt |more 
