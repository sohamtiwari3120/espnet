import argparse
import os
import pandas as pd

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_audio_dir', type=str, default="downloads/Speech_Audio_Data/Speech Data/")
    parser.add_argument('--input_splits_csv_dir', type=str, default="downloads/Data_Splits/Data")
    parser.add_argument('--output_dir', type=str, default="data/")
    return parser.parse_args()

def write_to_file(df, output_file, uttid_path_dict):
    wav_scp_fp = open(output_file, "w")
    for index, row in df.iterrows():
        uttid = row["time_stamp"]
        audio_path = uttid_path_dict[uttid]
        wav_scp_fp.write("{}\t{}\n".format(uttid, audio_path))
    wav_scp_fp.close()

def generate_wav_scp_file(args):
    uttid_path_dict = {}
    audio_folders = os.listdir(args.input_audio_dir)
    for audio_folder in audio_folders:
        chopped_audio_folder_path = os.path.abspath(os.path.join(args.input_audio_dir, audio_folder, "ChoppedAudio"))
        chopped_audios = os.listdir(chopped_audio_folder_path)
        for chopped_audio in chopped_audios:
            temp = chopped_audio.split('_')
            uttid_prefix = temp[0]
            uttid_suffix = temp[-1][:-4]
            audio_path = os.path.join(chopped_audio_folder_path, chopped_audio)
            uttid_path_dict[uttid_prefix+'_'+uttid_suffix] = audio_path
    test_csv = pd.read_csv(os.path.join(args.input_splits_csv_dir, "test.csv"))
    train_csv = pd.read_csv(os.path.join(args.input_splits_csv_dir, "train.csv"))
    dev_csv = pd.read_csv(os.path.join(args.input_splits_csv_dir, "dev.csv"))

    write_to_file(test_csv, os.path.join(args.output_dir, "test", "wav.scp"), uttid_path_dict)

    write_to_file(train_csv, os.path.join(args.output_dir, "train", "wav.scp"), uttid_path_dict)

    write_to_file(dev_csv, os.path.join(args.output_dir, "dev", "wav.scp"), uttid_path_dict)


if __name__ == '__main__':
    args = parse_args()
    generate_wav_scp_file(args)
    