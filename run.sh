#!/usr/bin/bash
make
./parser $1
dot -Tpdf parse.dot -otree.pdf
