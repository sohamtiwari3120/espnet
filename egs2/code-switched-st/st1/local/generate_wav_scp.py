import argparse


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=str, required=True)
    parser.add_argument('--output', type=str, required=True)
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    with open(args.input, 'r') as f:
        lines = f.readlines()
    with open(args.output, 'w') as f:
        for line in lines:
            line = line.strip()
            if line:
                f.write(line + '\n')
    