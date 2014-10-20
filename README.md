groovim_sync - Synchronizing directories via network using samba or compatible networking protocol!
=============

<img border="0" alt="GrooVim Doc" src="http://imageshack.com/a/img829/4064/meg6.png" height="15%" width="15%">GrooVim Doc

What is groovim_sync?
-----

**Note:** Actually no matter if you are using virtual machines or not since your development machine and the machine that running your code communicate using samba or compatible networking protocol!

It's a shell script (works like a "daemon") that uses the applications "inotify-tools" and "unison" for synchronizing directories via network using samba or compatible networking protocol. It's ideal for software development using virtualized environments (VMWare, VirtualBox...), enabling real-time manipulate files from your guest synchronizing them with local directory on your host. It's perfect for keeping local repositories on your host from multiple development environments and ease of use with repository technologies like Git, SVN and others doing everything in a unified way! Using it in conjunction with the <a href="https://github.com/eduardolucioac/groovim">**GrooVim**</a> (Vim mod) to form a practical and powerful development environment for multiple platforms, technologies and programming languages.

How to use!
-----

 * Install "inotify-tools" and "unison" applications (Debian based example)...

```
apt-get install inotify-tools
apt-get install unison
```

 * Make a copy of the file "Model.sh" and give it a name to identify which project it is. Examples: "MyProject.sh", "MyClientName.sh" and so on...
    - Note I: This file must be in the same directory as the file "GrooVimSync.sh"!
    - Note II: For different projects use different copies of the file "Model.sh". In that way you can have different settings for different projects easily!

 * Set the following attributes according to their descriptions in the "Model.sh" copy:
    - Note I: Create the follow directories on the host "DIR_MOUNT_SYNC_HOST" and "DIR_MOUNT_SYNC_GUEST" to synchronize. The "DIR_MOUNT_SYNC_GUEST" directory is where you will mount the "NET_SHARE_GUEST" network path and where you will manipulate your project files!
    - Note II: I recommend that for the first run "DIR_MOUNT_SYNC_HOST" and "NET_SHARE_GUEST" have copies of the same content!
    - Note III: The groovim_sync bidirectionally synchronize the directories "DIR_MOUNT_SYNC_HOST" and "DIR_MOUNT_SYNC_GUEST", however I recommend perform your development work using the directory "DIR_MOUNT_SYNC_GUEST" which is where we mount the network path!

```
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
```

 * Give execute permissions:

```
chmod a+x GrooVimSync.sh
chmod a+x ModelCopy.sh
```

 * Open a terminal and run...

```
sh ModelCopy.sh
```

... and let the magic happen!

    - Note: To exit type "quit" at the terminal!
