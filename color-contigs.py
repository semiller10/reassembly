#!/usr/bin/env python3

import argparse
from glob import glob
import os.path
import sys

colors = ["2F6D80", # Magenta
          "733E98", # Purple
          "2A66B1", # Blue
          "559FD7", # Sky Blue
          "C895C3", # Pink
          "67CAD5", # Light pink
          "9C2D44", # Dark red
          "E9815C", # Red
          "57AB57", # Orange
          "F3E945", # Yellow
          "BCDA82", # Peach
          "F8E5C0", # Tan
         ]

def main():

    args = get_args()
    bin_fastas = glob(os.path.join(args.dir, args.name + '.*.fa'))
    delim = args.delim

    n = 0
    out = ['name,color,bin\n']
    for bin_fasta in bin_fastas:
        hexcolor = colors[n]
        bin_label = os.path.basename(bin_fasta).split(args.name + '.')[1].split('.fa')[0]
        with open(bin_fasta) as handle:
            for line in handle.readlines():
                if line[0] == '>':
                    print(line, flush=True)
                    seq_id = line.split(delim)[1].rstrip()
                    out.append(seq_id + ',' + hexcolor + ',' + bin_label + '\n')
        n += 1
    with open(args.out, 'w') as handle:
        for line in out:
            handle.write(line)

    return

def get_args():

    parser = argparse.ArgumentParser(
        description=(
            'This script is a modified version of Barnum/Karkman script '
            'for producing a csv file for coloring contigs in Bandage, '
            'modified to color by bins produced by programs such as Metabat'
        )
    )
    parser.add_argument('-d', '--dir', help='Directory containing bins')
    parser.add_argument(
        '-n', '--name', help='Common bin name, where fasta files are titled <name>.<number>.fa'
    )
    parser.add_argument(
        '-e', '--delim', help='Contig delimiter in the assembly file, e.g., "k141_"'
    )
    parser.add_argument('-o', '--out', help='Output file')

    args = parser.parse_args()

    return args

if __name__ == '__main__':
    main()