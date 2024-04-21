#!/usr/bin/env bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

set -e

read -p "Enter the URL from email: " PRESIGNED_URL
echo ""
read -p "Enter the list of models to download without spaces (8B,8B-instruct,70B,70B-instruct), or press Enter for all: " MODEL_SIZE
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

if [[ $MODEL_SIZE == "" ]]; then
    MODEL_SIZE="8B,8B-instruct,70B,70B-instruct"
fi

echo "Downloading LICENSE and Acceptable Usage Policy"
curl -A "wget" ${PRESIGNED_URL/'*'/"LICENSE"} -o ${TARGET_FOLDER}"/LICENSE"
curl -A "wget" ${PRESIGNED_URL/'*'/"USE_POLICY.md"} -o ${TARGET_FOLDER}"/USE_POLICY.md"

for m in ${MODEL_SIZE//,/ }
do
    if [[ $m == "8B" ]] || [[ $m == "8b" ]]; then
        SHARD=0
        MODEL_FOLDER_PATH="Meta-Llama-3-8B"
        MODEL_PATH="8b_pre_trained"
    elif [[ $m == "8B-instruct" ]] || [[ $m == "8b-instruct" ]] || [[ $m == "8b-Instruct" ]] || [[ $m == "8B-Instruct" ]]; then
        SHARD=0
        MODEL_FOLDER_PATH="Meta-Llama-3-8B-Instruct"
        MODEL_PATH="8b_instruction_tuned"
    elif [[ $m == "70B" ]] || [[ $m == "70b" ]]; then
        SHARD=7
        MODEL_FOLDER_PATH="Meta-Llama-3-70B"
        MODEL_PATH="70b_pre_trained"
    elif [[ $m == "70B-instruct" ]] || [[ $m == "70b-instruct" ]] || [[ $m == "70b-Instruct" ]] || [[ $m == "70B-Instruct" ]]; then
        SHARD=7
        MODEL_FOLDER_PATH="Meta-Llama-3-70B-Instruct"
        MODEL_PATH="70b_instruction_tuned"
    fi

    echo "Downloading ${MODEL_PATH}"
    mkdir -p ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}"

    for s in $(seq -f "0%g" 0 ${SHARD})
    do
        curl -A "wget" ${PRESIGNED_URL/'*'/"${MODEL_PATH}/consolidated.${s}.pth"} -o ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}/consolidated.${s}.pth"
    done

    curl -A "wget" ${PRESIGNED_URL/'*'/"${MODEL_PATH}/params.json"} -o ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}/params.json"
    curl -A "wget" ${PRESIGNED_URL/'*'/"${MODEL_PATH}/tokenizer.model"} -o ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}/tokenizer.model"
    curl -A "wget" ${PRESIGNED_URL/'*'/"${MODEL_PATH}/checklist.chk"} -o ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}/checklist.chk"
    
    echo "Checking checksums"
    
    _IFS=$IFS
    IFS=$'\n'
    for line in $(cat ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}"/checklist.chk)
    do
        filehash=$(echo "$line" | cut -d" " -f 1)
        filename=$(echo "$line" | cut -d" " -f 3)
        
        if [[ $filehash == $(md5 ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}"/$filename | cut -d" " -f 4) ]]
        then
            echo "$filename: OK"
        else
            echo "$filename: FAILED"
        fi
    done
    IFS=$_IFS
done
