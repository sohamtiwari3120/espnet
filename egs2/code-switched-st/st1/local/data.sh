#!/usr/bin/env bash

#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;
. ./db.sh || exit 1;

# general configuration
stage=0       # start from 0 if you need to start from data preparation
stop_stage=100
SECONDS=0
tgt_lang=en # or 'hi'

 . utils/parse_options.sh || exit 1;


log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}

if [ -z "${PRABHUPADAVANI}" ]; then
    log "Fill the value of 'PRABHUPADAVANI' of db.sh"
    exit 1
fi

# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail


echo ${stage}

if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
    log "stage 0: Data Downloading"
    if [ -d "${PRABHUPADAVANI}/" ]; then
        echo "Deleting existing contents of ${PRABHUPADAVANI}"
        rm -rf "${PRABHUPADAVANI}"
    fi
    python local/download_speech_data.py 
    mv "11692 Speech Processing Data/" "${PRABHUPADAVANI}/"
    unzip "${PRABHUPADAVANI}/Data_Splits.zip" -d "${PRABHUPADAVANI}/Data_Splits/" && rm -rf "${PRABHUPADAVANI}/Data_Splits.zip"
    unzip "${PRABHUPADAVANI}/Speech_Audio_Data.zip" -d "${PRABHUPADAVANI}/Speech_Audio_Data/" && rm -rf "${PRABHUPADAVANI}/Speech_Audio_Data.zip"
    echo "Finished downloading"
fi

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
    log "stage 1: Data Preparation"
    # use underscore-separated names in data directories.
    mkdir -p data/train
    mkdir -p data/test
    mkdir -p data/dev
    # NOTE: train/dev/test splits are different from original CommonVoice
    python local/correct_train_csv.py
    python local/generate_wav_scp.py
    
    # Generate the text.tc.<language> files
    python local/generate_text_transcripts.py --lang English --input downloads/Data_Splits/Data/train.csv --output data/train/text.tc.en --normalize
    python local/generate_text_transcripts.py --lang English --input downloads/Data_Splits/Data/test.csv --output data/test/text.tc.en --normalize
    python local/generate_text_transcripts.py --lang English --input downloads/Data_Splits/Data/dev.csv --output data/dev/text.tc.en --normalize
    echo "Generated text.tc.en for train, dev and test splits"

    python local/generate_text_transcripts.py --lang Hindi --input downloads/Data_Splits/Data/train.csv --output data/train/text.tc.hi --normalize
    python local/generate_text_transcripts.py --lang Hindi --input downloads/Data_Splits/Data/test.csv --output data/test/text.tc.hi --normalize
    python local/generate_text_transcripts.py --lang Hindi --input downloads/Data_Splits/Data/dev.csv --output data/dev/text.tc.hi --normalize
    echo "Generated text.tc.hi for train, dev and test splits"

    # generating utt2spk and spk2utt dummy files
    python local/generate_utt_spk_files.py --folder data/train/
    python local/generate_utt_spk_files.py --folder data/test/
    python local/generate_utt_spk_files.py --folder data/dev/
    echo "Generated utt2spk and spk2utt dummy files for train, test and dev splits"
fi


log "Successfully finished. [elapsed=${SECONDS}s]"
