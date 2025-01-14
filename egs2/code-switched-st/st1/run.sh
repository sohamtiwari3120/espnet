#!/usr/bin/env bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

# CUDA_VISIBLE_DEVICES=1
# if [ -z "$CUDA_VISIBLE_DEVICES" ]; then
#     echo "Error: Argument must not be empty. You need to provide CUDA_VISIBLE_DEVICES value"
#     exit 1
# fi
# language related
echo "USING CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
src_lang=code_mixed
# tgt_lang=hi
tgt_lang=en
use_src_lang=false

# st_config=conf/train_st4_conformer_normalized.yaml
# st_config=conf/train_st8_branchformer_normalized_es10.yaml
st_config=conf/train_st9_conformer_normalized_es10.yaml
# st_config=conf/train_st6_branchformer_normalized.yaml
inference_config=conf/decode_st.yaml

# English (en)
# French (fr)
# German (de)
# Spanish (es)
# Catalan (ca)
# Italian (it)
# Russian (ru)
# Chinese (zh-CN)
# Portuguese (pt)
# Persian (fa)
# Estonian (et)
# Mongolian (mn)
# Dutch (nl)
# Turkish (tr)
# Arabic (ar)
# Swedish (sv-SE)
# Latvian (lv)
# Slovenian (sl)
# Tamil (ta)
# Japanese (ja)
# Indonesian (id)
# Welsh (cy)

src_nbpe=1000
tgt_nbpe=1000
src_case=lc.rm
tgt_case=tc

train_set=train
train_dev=dev
test_sets="test"
stage=2
# skip_train=true

# verify language directions
# is_exist=false
is_low_resource=false
# if [[ ${src_lang} == en ]]; then
#     tgt_langs=de_ca_zh-CN_fa_et_mn_tr_ar_sv-SE_lv_sl_ta_ja_id_cy
#     for lang in $(echo ${tgt_langs} | tr '_' ' '); do
#         if [[ ${lang} == "${tgt_lang}" ]]; then
#             is_exist=true
#             break
#         fi
#     done
# else
#     lr_src_langs=it_ru_zh-CN_pt_fa_et_mn_nl_tr_ar_sv-SE_lv_sl_ta_ja_id_cy
#     for lang in $(echo ${lr_src_langs} | tr '_' ' '); do
#         if [[ ${lang} == "${src_lang}" ]]; then
#             is_low_resource=true
#             break
#         fi
#     done
#     src_langs=fr_de_es_ca_it_ru_zh-CN_pt_fa_et_mn_nl_tr_ar_sv-SE_lv_sl_ta_ja_id_cy
#     for lang in $(echo ${src_langs} | tr '_' ' '); do
#         if [[ ${lang} == "${src_lang}" ]]; then
#             is_exist=true
#             break
#         fi
#     done
# fi
# if [[ ${is_exist} == false ]]; then
#     echo "No language direction: ${src_lang} to ${tgt_lang}" && exit 1;
# fi

if [ ${is_low_resource} = true ]; then
    speed_perturb_factors="0.8 0.9 1.0 1.1 1.2"
else
    speed_perturb_factors="0.9 1.0 1.1"
fi

# if [ ${src_lang} == ja ] || [ ${src_lang} == zh-CN ]; then
#     src_nbpe=4000
# fi

# if [ ${tgt_lang} == ja ] || [ ${tgt_lang} == zh-CN ]; then
#     tgt_nbpe=4000
# fi

./st.sh \
    --ngpu 1 \
    --stage ${stage} \
    --local_data_opts "0 --src_lang ${src_lang} --tgt_lang ${tgt_lang}" \
    --use_lm false \
    --feats_type raw \
    --audio_format "flac.ark" \
    --token_joint false \
    --src_lang ${src_lang} \
    --tgt_lang ${tgt_lang} \
    --use_src_lang ${use_src_lang} \
    --src_token_type "bpe" \
    --src_nbpe $src_nbpe \
    --tgt_token_type "bpe" \
    --tgt_nbpe $tgt_nbpe \
    --src_case ${src_case} \
    --tgt_case ${tgt_case} \
    --train_set "${train_set}" \
    --valid_set "${train_dev}" \
    --test_sets "${test_sets}" \
    --src_bpe_train_text "data/${train_set}/text.${src_case}.${src_lang}" \
    --tgt_bpe_train_text "data/${train_set}/text.${tgt_case}.${tgt_lang}" \
    --lm_train_text "data/${train_set}/text.${tgt_case}.${tgt_lang}" \
    --st_config "${st_config}" \
    --inference_config "${inference_config}" "$@"
    # --speed_perturb_factors "${speed_perturb_factors}" "$@"


# on new data
# find in error analysis using the different architectures
# demo for real time analysis
# error analysis being interesting is more important and finding insights
# future interesting work

# open source s2text implementations - espnet-st 
# Searchable Hidden Intermediates for End-to-End Models of Decomposable Sequence Tasks
# brian yan





