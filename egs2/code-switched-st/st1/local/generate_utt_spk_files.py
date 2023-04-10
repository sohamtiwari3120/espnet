import argparse
import os

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--folder', type=str, required=True)
    return parser.parse_args()

def generate_spk_utt_files(args):
    wav_scp_fp = open(os.path.join(args.folder, 'wav.scp'), "r")
    utt2spk_fp = open(os.path.join(args.folder, 'utt2spk'), "w")
    spk2utt_fp = open(os.path.join(args.folder, 'spk2utt'), "w")
    for i, line in enumerate(wav_scp_fp.readlines()):
        line = line.strip()
        if line:
            uttid = line.split('\t')[0]
            spkid = f"speaker_{i:07d}"
            utt2spk_fp.write(f"{uttid}\t{spkid}\n")
            spk2utt_fp.write(f"{spkid}\t{uttid}\n")
    wav_scp_fp.close()
    utt2spk_fp.close()
    spk2utt_fp.close()

if __name__ == '__main__':
    args = parse_args()
    generate_spk_utt_files(args)