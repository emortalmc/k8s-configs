#!/usr/bin/env bash

function run_script {
  cd "$1" || exit
  source ./$2
  cd ..
}

function run_init_script {
  run_script "$1" init.sh
}
