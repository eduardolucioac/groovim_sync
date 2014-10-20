#!/bin/bash

# Note: Samba User! By Questor 
NET_SHARE_USER="username"
# Note: Samba Password! By Questor 
NET_SHARE_PSW="password"

# Note: "samba share" of the virtual machine! By Questor 
NET_SHARE_GUEST="//172.16.13.132/Shared/DEV_GUESTS/PROJECT"

# Note: The folder to mount the "share" above! By Questor 
DIR_MOUNT_SYNC_GUEST="/home/username/Data/DEV_GUESTS/PROJECT"

# Note: Folder to synchronize the local backup! By Questor 
DIR_MOUNT_SYNC_HOST="/home/username/Data/DEV_HOST/PROJECT"

# Note: Sets the interval between each run of "unison" to catch changes made by the guest machine!
# Use 0 to disable. Most of the time this procedure is not necessary. Use it with care to not overload
# the machines! By Questor
GET_CHANGES_MADE_BY_GUEST_MACHINE_INTERVAL=0

# Note: Source the 2nd script, i.e. . test2.sh and it will run in the same shell. 
# This would let you share more complex variables like arrays easily, but also means 
# that the other script could modify variables in the source shell!
# [Ref.: http://stackoverflow.com/questions/9772036/pass-all-variables-from-one-shellscript-to-another]
# By Questor

. ./GrooVimSync.sh
