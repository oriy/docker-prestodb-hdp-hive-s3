#!/bin/bash

MAIN_BUCKET=bucket_for_schema_1

declare -a bucketNames=(
  ${MAIN_BUCKET}
  "bucket_for_schema_2"
  "bucket_for_schema_3"
)

#
## create buckets
#
for bucketName in "${bucketNames[@]}"
do
    awslocal s3api create-bucket --bucket ${bucketName}
done

declare -a schema1Tables=(
  "table_1"
)

#
## create folders for tables partitioned by date
#
for schema1Table in "${schema1Tables[@]}"
do
    awslocal s3api put-object --bucket ${MAIN_BUCKET} --key "${schema1Table}/date=$(date +%Y-%m-%d)/dummy"
done

echo
echo "> s3api list-buckets"
echo "$(awslocal s3api list-buckets)"

echo
echo "> s3 ls ${MAIN_BUCKET}"
echo "$(awslocal s3 ls ${MAIN_BUCKET})"
