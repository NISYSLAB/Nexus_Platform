
name=dicom2nii-DEV
echo "docker stop ${name}"
docker stop ${name}

docker ps -a