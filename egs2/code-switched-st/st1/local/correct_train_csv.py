import argparse
import pandas as pd

def correct_train_csv_incorrect_timestamp(args):
    df = pd.read_csv(args.train_csv_path)
    df['time_stamp'] = df.apply(lambda row: row['time_stamp'][:5]+'c'+row['time_stamp'][5:] if ("_clip" not in row["time_stamp"]) else row["time_stamp"], axis=1)
    df.to_csv(args.train_csv_path, index=False)

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--train_csv_path', type=str, default="downloads/Data_Splits/Data/train.csv")
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    correct_train_csv_incorrect_timestamp(args)