#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../test" && pwd )"

dart --enable-checked-mode $ROOT_DIR/hart_test.dart