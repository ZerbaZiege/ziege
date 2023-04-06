# Ziege Docker plugin

# # _zg_doc "ziege:: _zg_vpn_start: start the VPN"
# function _zg_vpn_start() {
#     sudo systemctl start surfsharkd2.service
# }

# # _zg_doc "ziege:: _zg_vpn_stop: stop the VPN"
# function _zg_vpn_stop () {
#     sudo systemctl stop surfsharkd2.service
# }

# _zg_doc "docker:: dk: run any docker command"
function dk() {
    docker ${@:1}
}

# _zg_doc "docker:: dk_build: docker build"
function dk_build() {
    _zg_run _vpn_stop
    dk build ${@:1}
    _zg_run _vpn_start
}


# _zg_doc "docker:: dk_run: docker run command"
function dk_run() {
    dk run ${@:1}
}

