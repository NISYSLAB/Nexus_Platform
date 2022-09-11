
name=dicom2nii-DEV
echo ""
echo "docker stop ${name}"
docker stop ${name}

docker ps -a
echo ""