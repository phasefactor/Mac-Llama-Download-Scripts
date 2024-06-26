#!/bin/bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

# Updated to run on base install of MacOS.

read -p "Enter the URL from email: " PRESIGNED_URL
echo ""
ALL_MODELS="7b,13b,34b,70b,7b-Python,13b-Python,34b-Python,70b-Python,7b-Instruct,13b-Instruct,34b-Instruct,70b-Instruct"
read -p "Enter the list of models to download without spaces ($ALL_MODELS), or press Enter for all: " MODEL_SIZE
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

if [[ $MODEL_SIZE == "" ]]; then
    MODEL_SIZE=$ALL_MODELS
fi

echo "Downloading LICENSE and Acceptable Usage Policy"
curl -A "wget" ${PRESIGNED_URL/'*'/"LICENSE"} -o ${TARGET_FOLDER}"/LICENSE"
curl -A "wget" ${PRESIGNED_URL/'*'/"USE_POLICY.md"} -o ${TARGET_FOLDER}"/USE_POLICY.md"

for m in ${MODEL_SIZE//,/ }
do
    case $m in
      7b)
        SHARD=0 ;;
      13b)
        SHARD=1 ;;
      34b)
        SHARD=3 ;;
      70b)
        SHARD=7 ;;
      7b-Python)
        SHARD=0 ;;
      13b-Python)
        SHARD=1 ;;
      34b-Python)
        SHARD=3 ;;
      70b-Python)
        SHARD=7 ;;
      7b-Instruct)
        SHARD=0 ;;
      13b-Instruct)
        SHARD=1 ;;
      34b-Instruct)
        SHARD=3 ;;
      70b-Instruct)
        SHARD=7 ;;
      *)
        echo "Unknown model: $m"
        exit 1
    esac

    MODEL_PATH="CodeLlama-$m"
    echo "Downloading ${MODEL_PATH}"
    mkdir -p ${TARGET_FOLDER}"/${MODEL_PATH}"

    for s in $(seq -f "0%g" 0 ${SHARD})
    do
        curl -A "wget" ${PRESIGNED_URL/'*'/"${MODEL_PATH}/consolidated.${s}.pth"} -o ${TARGET_FOLDER}"/${MODEL_PATH}/consolidated.${s}.pth"
    done

    curl -A "wget" ${PRESIGNED_URL/'*'/"${MODEL_PATH}/params.json"} -o ${TARGET_FOLDER}"/${MODEL_PATH}/params.json"
    curl -A "wget" ${PRESIGNED_URL/'*'/"${MODEL_PATH}/tokenizer.model"} -o ${TARGET_FOLDER}"/${MODEL_PATH}/tokenizer.model"
    curl -A "wget" ${PRESIGNED_URL/'*'/"${MODEL_PATH}/checklist.chk"} -o ${TARGET_FOLDER}"/${MODEL_PATH}/checklist.chk"
    
    echo "Checking checksums"
    
    _IFS=$IFS
    IFS=$'\n'
    for line in $(cat ${TARGET_FOLDER}"/${MODEL_PATH}"/checklist.chk)
    do
        filehash=$(echo "$line" | cut -d" " -f 1)
        filename=$(echo "$line" | cut -d" " -f 3)
        
        if [[ $filehash == $(md5 ${TARGET_FOLDER}"/${MODEL_PATH}"/$filename | cut -d" " -f 4) ]]
        then
            echo "$filename: OK"
        else
            echo "$filename: FAILED"
        fi
    done
    IFS=$_IFS
done
