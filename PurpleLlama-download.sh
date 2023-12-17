#!/usr/bin/env bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

# Updated to run on base install of MacOS.

set -e
read -p "Enter the URL from email: " PRESIGNED_URL
echo ""
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

echo "Downloading LICENSE and Acceptable Usage Policy"
curl -A "wget" ${PRESIGNED_URL/'*'/"LICENSE"} -o ${TARGET_FOLDER}"/LICENSE"
curl -A "wget" ${PRESIGNED_URL/'*'/"USE_POLICY.md"} -o ${TARGET_FOLDER}"/USE_POLICY.md"

echo "Downloading tokenizer"
curl -A "wget" ${PRESIGNED_URL/'*'/"tokenizer.model"} -o ${TARGET_FOLDER}"/tokenizer.model"

mkdir -p ${TARGET_FOLDER}"/llama-guard"

curl -A "wget" ${PRESIGNED_URL/'*'/"consolidated.00.pth"} -o ${TARGET_FOLDER}"/llama-guard/consolidated.00.pth"
curl -A "wget" ${PRESIGNED_URL/'*'/"params.json"} -o ${TARGET_FOLDER}"/llama-guard/params.json"
