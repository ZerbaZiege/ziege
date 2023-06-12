# Ziege Docker plugin

# # _zg_doc "ziege:: _zg_vpn_start: start the VPN"
# function _zg_vpn_start() {
#     sudo systemctl start surfsharkd2.service
# }

# # _zg_doc "ziege:: _zg_vpn_stop: stop the VPN"
# function _zg_vpn_stop () {
#     sudo systemctl stop surfsharkd2.service
# }

# _zg_doc "docker:: dk: Run a docker command. With no arguments, prints dk* help."
function dk () {
  if [[ -z "$1" ]]; then
    cat <<EOF
docker convenience functions

dk - Run a docker command
docker_arch - Determine the docker architecture values - echo "\$_REPLY"
docker_ecr_login/dk_ecr - Log in to local AWS ECR repository. Requires AWS SSO or MFA session
docker_run/dk_zsh [arch] - Run the specified image in docker. Defaults to platform architecture

EOF
    return 1
  fi
	command docker ${@:1}
}

# _zg_doc "docker:: docker_arch: Generate architecture settings for docker ARCH= and '--platform linux/* values'. Sets _REPLY array"
function docker_arch() {
  local arch_name="$(uname -m)"
  local intel_or_rosetta
  local apple_silicon
  local dkr_arch

  if [[ $arch_name = "x86_64" ]]; then
      if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
          # echo "Running on Rosetta 2"
          intel_or_rosetta="TRUE"
      else
          # echo "Running on native Intel"
          intel_or_rosetta="TRUE"
      fi 
  elif [[ $arch_name = "arm64" ]]; then
      # echo "Running on ARM"
      apple_silicon="TRUE"
  else
      echo "Unknown architecture: $arch_name"
      exit 1
  fi

  dk_arch="amd64"
  if [[ $apple_silicon == "TRUE" ]]; then
    dk_arch="arm64"
  fi  

  export _REPLY=($arch_name $dk_arch)
}

# _zg_doc "docker:: docker_ecr_login: Log into an AWS ECR repository"
function docker_ecr_login() {
  local aws_account_id=${AWS_ACCOUNT_ID:-282403293636}
  local aws_region=${AWS_DEFAULT_REGION:-us-east-1}
  aws ecr get-login-password --region $aws_region | dk login -u AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com
}

# _zg_doc "docker:: dk_ecr: alias for docker_ecr_login"
alias dk_ecr=docker_ecr_login

# _zg_doc "docker:: dk_build: docker build"
function dk_build() {
    _zg_run _vpn_stop
    dk build ${@:1}
    _zg_run _vpn_start
}


# _zg_doc "docker:: docker_run: docker_run_zsh [ARCH] IMAGE_NAME - run specified Docker image and invoke zsh"
function docker_run_zsh() {
  if [[ -n $2 ]]; then
    local local_arch=$1
    shift
  fi
  if [[ -n $1 ]]; then
    image_name=$1
    local arch1
    local arch2
    if [[ -n ${local_arch:-} ]]; then
      if [[ $local_arch == 'amd64' ]]; then
        arch1="x86_64"
      else
        arch1=$local_arch
      fi
      arch2=$local_arch
    else
      docker_arch
      arch1=$_REPLY[1]
      arch2=$_REPLY[2]
    fi
    ARCH=$arch1 dk run --platform linux/$arch2 --rm -it $image_name  /bin/zsh
  fi
}

# _zg_doc "docker:: dk_zsh: alias for docker_run_zsh"
alias dk_zsh=docker_run_zsh

