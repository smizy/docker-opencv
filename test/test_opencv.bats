@test "opencv is the correct version" {
  run docker run smizy/opencv:${TAG} python -c 'import cv2; print(cv2.__version__)'
  echo "${output}" 

  [ $status -eq 0 ]

  result="${lines[0]}"

  [ "${result%.*}" = "${VERSION%.*}" ]
}