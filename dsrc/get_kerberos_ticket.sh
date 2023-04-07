#!/usr/bin/env bash

export KRB_DIR=/usr/local/krb5/bin;
export OSSH_DIR=/usr/local/ossh/bin;
export command_pkinit=/usr/local/krb5/bin/pkinit;
export command_klist=/usr/local/krb5/bin/klist;
export KRB_PRINCIPLE="cwood@HPCMP.HPC.MIL";
export USER_TICKET_DIR="/Users/cwood/tickets/tkt";

if [ ! -d "${KRB_DIR}" ];
then
    echo "WARNING: KRB_DIR (${KRB_DIR}) not found.";
    echo "Aborting ticket attempt, resolve the directory location first.";
    exit 1;
fi

if [ ! -d "${OSSH_DIR}" ];
then
    echo "WARNING: OSSH_DIR (${OSSH_DIR}) not found.";
    echo "Aborting ticket attempt, resolve the directory location first.";
    exit 1;
fi

export PATH=/usr/local/krb5/bin:/usr/local/ossh/bin:${PATH}


PKINIT_FOUND=$(which pkinit);
if [ ! -f "${command_pkinit}" ];
then
    echo "WARNING: pkinit (${command_pkinit}) not found.";
    echo "WARNING: (${PKINIT_FOUND}) was found here.";
    echo "Aborting ticket attempt, resolve the pkinit location first.";
    exit 1;
fi

KLIST_FOUND=$(which klist);
if [ ! -f "${command_klist}" ];
then
    echo "WARNING: klist (${command_klist}) not found.";
    echo "WARNING: (${KLIST_FOUND}) was found here.";
    echo "Aborting ticket attempt, resolve the klist location first.";
    exit 1;
fi

export KRB5_CONFIG=/etc/krb5.conf
if [ ! -f "${KRB5_CONFIG}" ];
then
    echo "WARNING: krb5.conf (${KRB5_CONFIG}) not found.";
    echo "Aborting ticket attempt, resolve the krb5 config location first.";
    exit 1;
fi

#KRB5CCNAME=DIR::/Users/cwood/tickets/tkt /usr/local/krb5/bin/pkinit cwood@HPCMP.HPC.MIL
KRB5CCNAME=DIR::"${USER_TICKET_DIR}" $command_pkinit "${KRB_PRINCIPLE}";
$command_klist

exit 0
