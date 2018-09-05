#!/bin/bash

ver=2
name=`basename $PWD`
docker_tag=broadcptac/$name:$ver


mkdir src

# copy code files from src-directory
#cp -r ../../src/$name/* src
cp -r ../../src/* src
dos2unix src/*

docker build --rm -t $docker_tag .

rm -R src/
#rm *.R
