#!/usr/bin/env bash
set -eu

if [[ $# < 1 ]]; then
    echo "[Usage] bash $0 <profile>" >&2
    exit 1
elif [[ $# < 2 ]]; then
    DDL_OUTPUT_DIR=.
else
    DDL_OUTPUT_DIR=$2
fi


role_arn=`aws configure get role_arn --profile $1`
sts_result=`aws --profile $1 sts assume-role --role-arn ${role_arn} --role-session-name extract_ddl_session --duration-seconds 900`
export AWS_ACCESS_KEY_ID=`echo ${sts_result} | jq -r '.Credentials.AccessKeyId'`
export AWS_SECRET_ACCESS_KEY=`echo ${sts_result} | jq -r '.Credentials.SecretAccessKey'`
export AWS_SESSION_TOKEN=`echo ${sts_result} | jq -r '.Credentials.SessionToken'`
export AWS_SDK_LOAD_CONFIG=true
export AWS_DEFAULT_REGION=ap-northeast-1
unset AWS_PROFILE

TOOL_DIR=$(dirname $(python -c "import os; print(os.path.realpath('$0'));"))

CLUSTER=cluster_name
DATABASE=dev
USER=root
TABLE_DDL_QUERY=$TOOL_DIR/extract_table_ddl.sql
EXTERNAL_DDL_QUERY=$TOOL_DIR/extract_external_table_ddl.sql

export AWS_PROFILE=$1
redshift -C $CLUSTER -D $DATABASE -U $USER -f $TABLE_DDL_QUERY | \
    python $TOOL_DIR/split_each_table.py -d $DDL_OUTPUT_DIR
redshift -C $CLUSTER -D $DATABASE -U $USER -f $EXTERNAL_DDL_QUERY | \
    python $TOOL_DIR/split_each_table.py -d $DDL_OUTPUT_DIR

