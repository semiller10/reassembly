#!/usr/bin/env python

import argparse

def main():
    args = get_args()
    min_len = args.min

    with open(args.reads) as rh, open(args.out, 'w') as wh:
        block_count = 0
        for line in rh:
            if block_count == 0:
                first_hdr = line
                block_count += 1
            elif block_count == 1:
                first_seq = line
                block_count += 1
            elif block_count == 2:
                second_hdr = line
                block_count += 1
            elif block_count == 3:
                second_seq = line
                if len(first_seq.rstrip()) >= min_len and len(second_seq.rstrip()) >= min_len:
                    wh.write(first_hdr + first_seq + second_hdr + second_seq)
                block_count = 0

    return

def get_args():

    parser = argparse.ArgumentParser(
        description='Remove short paired-end reads'
    )
    parser.add_argument('-m', '--min', type=int, help='Minimum read length')
    parser.add_argument(
        '-r', '--reads', help='Fasta of interleaved reads -- must have unwrapped sequences'
    )
    parser.add_argument(
        '-o', '--out', help='Fasta output'
    )

    args = parser.parse_args()

    return args

if __name__ == '__main__':
    main()