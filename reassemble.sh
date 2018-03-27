#!/bin/bash

BIN_TABLE="$1"
READS_OUT="$2"
NAME=$(basename "${READS_OUT%.fasta}")
DIR=$(dirname "${READS_OUT}")
THREADS="$3"

# Recover reads from collection of bins
module unload python
module load python/3.5-2017q2
source ~/virtual-envs/anvio-4/bin/activate
bins-to-reads.py -t "$BIN_TABLE" -o "$READS_OUT"
deactivate
module unload python

# Assemble reads
megahit --12 "$READS_OUT" -o "$DIR"/megahit_out --presets meta-sensitive -t "$THREADS"
megahit_toolkit contig2fastg 141 "$DIR"/megahit_out/intermediate_contigs/k141.contigs.fa > "$DIR"/megahit_out/k141.fastg

# Map reads
module load java/1.8
cd "$DIR"
bbmap.sh ref="$DIR"/megahit_out/final.contigs.fa
bbmap.sh in="$READS_OUT" out="$DIR"/"$NAME".sam bamscript=bs.sh; sh bs.sh
module unload java/1.8

# Bin contigs
module load python/2.7-2015q2
jgi_summarize_bam_contig_depths --outputDepth "$DIR"/"$NAME"_depth.txt "$DIR"/"$NAME"_sorted.bam
metabat2 -i "$DIR"/megahit_out/final.contigs.fa -a "$DIR"/"$NAME"_depth.txt -o "$DIR"/reassembled_bins/reassembled_bins -m 2500 -t "$THREADS"

checkm lineage_wf -x fa -t "$THREADS" "$DIR"/reassembled_bins "$DIR"/reassembled_bins/checkm > "$DIR"/reassembled_bins/checkm_out.txt
module unload python

module load python/3.5-2017q2
color-contigs.py -d "$DIR"/reassembled_bins -n reassembled_bins -e k141_ -o "$DIR"/reassembled_bins/bin_colors.csv
module unload python