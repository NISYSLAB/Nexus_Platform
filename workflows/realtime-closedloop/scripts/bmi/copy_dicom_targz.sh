##cp  $PWD/test-data/siemens/fmri/001/*.dcm ../../emory_siemens_scanner_in_dir/
PIPELINE_LISTENER_DIR=/labs/mahmoudilab/synergy_remote_data1/rtcl_data_in_dir

SRC_DIR=/labs/mahmoudilab/synergy_remote_data1/emory_siemens_scanner_in_dir.backup/dcm

uid=$( uuidgen | head -c 12 )
for FILE in ${SRC_DIR}/*.tar.gz 
do 
  echo "copy $FILE to "$PIPELINE_LISTENER_DIR"/"$uid"_$( basename $FILE )"

  cp "$FILE" "$PIPELINE_LISTENER_DIR"/"$uid"_$( basename $FILE )
  sleep 1
done

