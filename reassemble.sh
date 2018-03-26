#!/bin/bash

BIN_TABLE="$1"
READS_OUT="$2"
NAME=$(basename "${READS_OUT}")
DIR=$(dirname "${READS_OUT}")
THREADS="$3"

# Recover reads from collection of bins
module load python/3.5-2017q2
bins-to-reads.py -t "$BIN_TABLE" -o "$READS_OUT"
module unload python

# Assemble reads
megahit --12 "$READS_OUT" -o "$DIR"/megahit_out --k-min 21 --k-max 121 --k-step 10 -t "$THREADS"
megahit_toolkit contig2fastg 121 "$DIR"/megahit_out/intermediate_contigs/k121.contigs.fa > k121.fastg

# Map reads
module load java/1.8
bbmap.sh ref="$DIR"/megahit_out/final.contigs.fa
bbmap.sh in="$READS_OUT" out="$DIR"/"$NAME".sam bamscript=bs.sh; sh bs.sh
module unload java/1.8

# Bin contigs
module load python/2.7-2015q2
jgi_summarize_bam_contig_depths --outputDepth "$DIR"/"$NAME"_depth.txt "$NAME".bam
metabat -i "$DIR"/megahit_out/final.contigs.fa -a "$DIR"/"$NAME"_depth.txt -o "$DIR"/reassembled_bins -m 2500 -t "$threads" > metabat.out
module unload python