#!/usr/bin/env bash

PATH_TO_FILE=$1
FILE_TIMESTAMP=$2
BUCKET="s3://ayk/backup/homer"

CURRENT_DIR=$(pwd)

docker compose down

docker volume rm mongo

set -e

doRestoreForVolume() {
  VOLUME=$1

  FILE_NAME="$VOLUME-$FILE_TIMESTAMP.tar.gz"
  FILE="$PATH_TO_FILE/$FILE_NAME"
  if [ ! -f $FILE ]; then
    FILE_NAME_IN_BUCKET="$BUCKET/$FILE_NAME"
    echo Downloading backup from $FILE_NAME_IN_BUCKET...
    aws s3 cp $FILE_NAME_IN_BUCKET $FILE
  fi
  echo Restoring backup from file $FILE...

  cp $FILE .
  docker run --rm \
    -v $VOLUME:/$VOLUME \
    -v $CURRENT_DIR:/backup \
    busybox tar -xzf /backup/$FILE_NAME
  rm $FILE_NAME
}

doRestoreForVolume "mongo"

docker compose up -d

echo Done!


