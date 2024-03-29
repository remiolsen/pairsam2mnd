#!/bin/bash

usage() { echo "Usage: $0 -i <pairsam.gz> -o <mndfile.txt>" 1>&2; exit 1; }

dname=`dirname "$0"`
threads=16
tmpdir=$SNIC_TMP

while getopts ":i:o:" opt; do
  case ${opt} in
    i) infile=${OPTARG} ;;
    o) outfile=${OPTARG} ;;
    t) threads=${OPTARG} ;;
    *) usage;;
  esac
done

shift $((OPTIND-1))
if [ -z "${infile}" ] || [ -z "${outfile}" ]; then
    usage
fi

if hash parallel 2>/dev/null; then
    pigz -p $threads -c -d $infile > $tmpdir/tmp.pairsam
    parallel -j $threads --block -1 --pipepart -a $tmpdir/tmp.pairsam $dname/get_mndfields.py | \
    sort -k2,2d -k6,6d --parallel=$threads > $outfile
else
    echo "Error: gnu parallel not found"
fi
