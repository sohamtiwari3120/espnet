import gdown
import argparse

def download_file(args):
    gdown.download_folder(id=args.folder_id, quiet=False, use_cookies=False)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-fid', '--folder_id', type=str, default='1W9iOi9MsnEUFxpwHOeFM_pmfJnt4lqZB')
    args = parser.parse_args()
    download_file(args)

                        