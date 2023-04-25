# Create text.tc.en (English) and text.tc.hi (Hindi) 
# Uses Kaldi format specified here - https://github.com/espnet/data_example

import argparse
import pandas as pd
import csv
from nltk.tokenize import WordPunctTokenizer
from indicnlp.tokenize.indic_tokenize import trivial_tokenize_indic
from indicnlp.normalize.indic_normalize import DevanagariNormalizer

def parse_args():
    # Take in input csv, target language, and output file
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=str, required=True)
    parser.add_argument('--lang', type=str, required=True)
    parser.add_argument('--output', type=str, required=True)
    parser.add_argument('--normalize', action='store_true')
    return parser.parse_args()

def normalize(txt):
    txt = txt.strip()
    if len(txt) == 0 or txt is None:
        txt = "."
    if not (args.lang == "Hindi" or args.lang == "English"):
        raise NotImplementedError("The only languages implemented right now are English or Hindi.")
    if args.lang == "Hindi":
        # hindi script normalization
        txt = DevanagariNormalizer().normalize(txt)
        # punctuation tokenization
        tokens = trivial_tokenize_indic(txt)
    elif args.lang == "English":
        txt = txt.upper()
        tokens = WordPunctTokenizer().tokenize(txt)
    normalized_txt =  " ".join(tokens) 
    return normalized_txt


if __name__ == '__main__':
    args = parse_args()
    
    # Read input CSV
    try:
        file_csv = pd.read_csv(args.input)
    except:
        raise Exception("Error reading input file. Check input path.")
    # Select specified language
    col_name = f"{args.lang}[100%].srt"
    try:
        train_lang = file_csv[['time_stamp', col_name]]
    except:
        raise Exception("Error selecting language. Make sure it's specified like English or Hindi")
    
    # If specified, normalize
    if args.normalize:
        print("Normalizing!")
        try:
            pd.options.mode.chained_assignment = None
            txt_normalized = train_lang.loc[:,col_name].apply(normalize)
            train_lang.loc[:,col_name] = txt_normalized.copy()
        except:
            raise Exception("Error normalizing text.")
    # Write output
    try:
        train_lang.to_csv(args.output, 
                          sep=' ', header=False, index=False,  quotechar="",  escapechar=" ", 
                          quoting=csv.QUOTE_NONE)
    except:
        raise Exception("Error writing output file. Check that the directory exists.")