#!/usr/bin/env bash

function run_script {
  cd "$1" || exit
  source ./$2
  cd ..
}

function run_init_script {
  run_script "$1" init.sh
}

function run_script_in_line {
  cd "$1" || exit
  source . "$2"
  cd ..
}

function run_init_script_in_line {
  run_script_in_line "$1" init.sh
}
