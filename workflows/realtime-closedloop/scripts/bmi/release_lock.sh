
LOCKDIR=/tmp/synergy/extraction_lock
rm -rf  $(dirname ${LOCKDIR} )/*lock
echo "Under LOCKDIR: $LOCKDIR"
ls $(dirname ${LOCKDIR} )/

