# Create text.tc.en (English) and text.tc.hi (Hindi) 
# Uses Kaldi format specified here - https://github.com/espnet/data_example

import argparse
import pandas as pd
import csv


def parse_args():
    # Take in input csv, target language, and output file
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=str, required=True)
    parser.add_argument('--lang', type=str, required=True)
    parser.add_argument('--output', type=str, required=True)
    return parser.parse_args()

def generate_text(args):
    try:
        file_csv = pd.read_csv(args.input)
    except:
        raise Exception("Error reading input file. Check input path.")
    # Select specified language
    try:
        train_lang = file_csv[['time_stamp',f"{args.lang}[100%].srt"]]
        drop_index = train_lang[train_lang['time_stamp'].str.contains("0580_clip36")].index
        train_lang = train_lang.drop(drop_index)
    except:
        raise Exception("Error selecting language. Make sure it's specified like English or Hindi")
    
    # Write output
    try:
        train_lang.to_csv(args.output, 
                          sep=' ', header=False, index=False,  quotechar="",  escapechar=" ", 
                          quoting=csv.QUOTE_NONE)
    except:
        raise Exception("Error writing output file. Check that the directory exists.")

if __name__ == '__main__':
    args = parse_args()
    # Read input CSV
    generate_text(args)