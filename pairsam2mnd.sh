#!/bin/bash

usage() { echo "Usage: $0 -i <pairsam.gz> -o <mndfile.txt>" 1>&2; exit 1; }

dname=`dirname "$0"`
pigz_t=16
py_t=16

while getopts ":i:o:" opt; do
  case ${opt} in
    i) infile=${OPTARG} ;;
    o) outfile=${OPTARG} ;;
    *) usage;;
  esac
done

shift $((OPTIND-1))
if [ -z "${infile}" ] || [ -z "${outfile}" ]; then
    usage
fi

if hash parallel 2>/dev/null; then
    pigz -p $pigz_t -c -d $infile > tmp.pairsam
    echo parallel -j $py_t --block -1 --pipepart -a tmp.pairsam $dname/get_mndfields.py | \
    sort -m -k2,2d -k6,6d --parallel=$sort_t > $outfile
    #rm tmp.pairsam
else
    echo "Error: gnu parallel not found"
fi