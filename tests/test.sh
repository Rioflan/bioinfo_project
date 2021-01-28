#!/bin/bash

if [ "$#" -ne 1 ]; then
  >&2 echo "Please use $0 <exec_path>"
  exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function echo_ok() {
  echo -e "[${GREEN}OK${NC}]"
}

function echo_ko() {
  echo -e "[${RED}KO${NC}]"
}

function assert_ret() {
  if [ "$(echo $?)" -eq "$1" ]; then
    echo_ok
  else
    echo_ko
  fi
}

function assert_equal() {
  if [ "$1" -eq "$2" ]; then
    echo_ok
  else
    echo_ko
  fi
}

EXEC_PATH="$(realpath $1)"

echo "Test 1: nwalign score YOYO YOYO"
$EXEC_PATH >/dev/null 2>&1 score YOYO YOYO
assert_ret 1

echo "Test 2: nwalign yoyo AAAA AAA"
$EXEC_PATH >/dev/null 2>&1 yoyo AAAA AAA
assert_ret 1

echo "Test 3: nwalign score AAAA AAAA"
output="$($EXEC_PATH score AAAA AAAA)"
ret_code="$(echo $?)"
if [ "$output" = '4.0' ]; then
  echo_ok
else
  echo_ko
fi
assert_equal 0 $ret_code


echo "Test 4: nwalign score ATG ACTG"
if [ "$($EXEC_PATH score ATG ACTG)" = '2.0' ]; then
  echo_ok
else
  echo_ko
fi

echo "Test 5: nwalign align ATG ACTG"
expected="$(cat <<EOF
A-TG
ACTG
EOF
)"
if [ "$($EXEC_PATH align ATG ACTG)" = "$expected" ]; then
  echo_ok
else
  echo_ko
fi

echo "Test 6: nwalign score TAT ATGAC"
if [ "$($EXEC_PATH score TAT ATGAC)" = '-1.0' ]; then
  echo_ok
else
  echo_ko
fi

echo "Test 7: nwalign align TAT ATGAC"
expected="$(cat <<EOF
-T-AT
ATGAC
EOF
)"
if [ "$($EXEC_PATH align TAT ATGAC)" = "$expected" ]; then
  echo_ok
else
  echo_ko
fi

echo "Test 8: nwalign --gamma=0,-1 score TAT ATGAC"
if [ "$($EXEC_PATH --gamma=0,-1 score TAT ATGAC)" = '0.0' ]; then
  echo_ok
else
  echo_ko
fi

echo "Test 9: nwalign --gamma=0,-1 align TAT ATGAC"
expected="$(cat <<EOF
TAT---
-ATGAC
EOF
)"
if [ "$($EXEC_PATH --gamma=0,-1 align TAT ATGAC)" = "$expected" ]; then
  echo_ok
else
  echo_ko
fi

echo "Test 10: nwalign --gamma=-1,-1 score SBZSKDAMKLHLILEGSVNGHCFEIHGEGEG SLSKDAMKLHLVNGHCFNIHGRGEG"
if [ "$($EXEC_PATH --gamma=-1,-1 score SBZSKDAMKLHLILEGSVNGHCFEIHGEGEG SLSKDAMKLHLVNGHCFNIHGRGEG)" = '111.0' ]; then
  echo_ok
else
  echo_ko
fi

echo "Test 11: nwalign --gamma=-1,-1 align SBZSKDAMKLHLILEGSVNGHCFEIHGEGEG SLSKDAMKLHLVNGHCFNIHGRGEG"
expected="$(cat <<EOF
SBZSKDAMKLHLILEGSVNGHCFEIHGEGEG
S-LSKDAMKLHL-----VNGHCFNIHGRGEG
EOF
)"
if [ "$($EXEC_PATH --gamma=-1,-1 align SBZSKDAMKLHLILEGSVNGHCFEIHGEGEG SLSKDAMKLHLVNGHCFNIHGRGEG)" = "$expected" ]; then
  echo_ok
else
  echo_ko
fi