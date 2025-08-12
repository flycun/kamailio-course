#!/bin/sh
prep_term()
{
    unset term_child_pid
    unset term_kill_needed
    trap 'handle_term' TERM INT
}

handle_term()
{
    if [ "${term_child_pid}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    else
        term_kill_needed="yes"
    fi
}

wait_term()
{
    term_child_pid=$!
    if [ "${term_kill_needed}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    fi
    wait ${term_child_pid}
    trap - TERM INT
    wait ${term_child_pid}
}

# KAM_IP_PUBLIC=`dig +short myip.opendns.com @resolver1.opendns.com`

prep_term
# echo 65535 > /writeable-proc/sys/net/core/somaxconn
# /usr/local/sbin/kamailio -DD -dd -E -e -m 256 -M 12 \
/usr/sbin/kamailio -S -DD -dd -E -e -m 32 -M 2 \
  -A KAM_SIP_PORT=$KAM_SIP_PORT \
  -A KAM_SIP_TLS_PORT=$KAM_SIP_TLS_PORT \
  -A KAM_IP_LOCAL=$(ip route get 8.8.8.8 | awk 'NR==1 {print $7}') \
#   -A KAM_IP_PUBLIC=$KAM_IP_PUBLIC \
#   -A KAM_CLUSTER_NONCE=\"$KAM_CLUSTER_NONCE\" \
#   -A KAM_CONTACT=\"$KAM_IP_PUBLIC:$KAM_SIP_PORT\" \
  $KAMAILIO_LOCATION

wait_term
