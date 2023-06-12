#!/usr/bin/env zsh

# Ziege Terraform plugin

# _zg_doc "terraform:: tf: Run any terraform command. Compatible with tfenv"
function tf() {
    command terraform ${@:1}
}

# _zg_doc "terraform:: tfi: Initialize the current terraform environment"
function tfi() {
  tf init
}

# _zg_doc "terraform:: tfv: Validate the syntax for the current terraform environment"
function tfv() {
  tf validate
}

# _zg_doc "terraform:: tfp: 'terraform plan' and save output"
function tfp() {
    local output_dir="$HOME/tmp/tfp"
    local dt_stamp=$(date "+%Y%m%d_%H%M%S")
    local rand_num=$(_zsh_prnd 10000 99999)
    
    export TF_OUT=current.tfplan
    
    mkdir -p $output_dir
    local tf_std_out=$(printf "%s/tfp_%s.txt" $output_dir $dt_stamp)
    export TF_STD_OUT=$tf_std_out

    tf plan -parallelism=30 -no-color -out $TF_OUT ${@:1}  | tee $TF_STD_OUT
    echo "Output saved in $TF_STD_OUT"

    local output_file_name=$(ls -1t $output_dir | head -n 1)
    local output_file_path=$(printf "%s/%s" $output_dir $output_file_name)
    command code -n $output_file_path
}

# _zg_doc "terraform:: tfa: 'terraform apply' results of previous 'tfp' "
function tfa() {
    if [[ -f $TF_OUT ]]; then
        tf apply -parallelism=30 ${@:1} -no-color "$TF_OUT"
    else
        tf apply -parallelism=30 ${@:1} -no-color
    fi
}

