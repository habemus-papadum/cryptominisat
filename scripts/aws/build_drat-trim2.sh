#!/bin/bash
set -e

cd /home/ubuntu
git clone https://github.com/msoos/drat-trim.git
cd drat-trim
cmake .
make

#binary is now at:
# drat-trim/drat-trim

cd /home/ubuntu
