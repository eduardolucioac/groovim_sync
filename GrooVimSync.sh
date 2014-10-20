

# Note: Esse script possui as seguintes dependências! By Questor
# apt-get install inotify-tools
# apt-get install unison


# Note: Tenta deletar a pasta "SYNC_CTRL_OFF" em caso de falha anterior (guest)! By Questor
if [ -d "${DIR_MOUNT_SYNC_GUEST}/SYNC_CTRL_OFF" ] ; then
	rm -r "${DIR_MOUNT_SYNC_GUEST}/SYNC_CTRL_OFF"
fi

# Note: Tenta deletar a pasta "SYNC_CTRL_OFF" em caso de falha anterior (host)! By Questor
if [ -d "${DIR_MOUNT_SYNC_HOST}/SYNC_CTRL_OFF" ] ; then
	rm -r "${DIR_MOUNT_SYNC_HOST}/SYNC_CTRL_OFF"
fi

KEEP_RUNNING=1

unison_excuter() {
	EXECUTER=$1
	# Note: Só permite sincronização se o diretório do guest estiver efetivamente acessível! By Questor
	if [ "$(ls -A $DIR_MOUNT_SYNC_GUEST)" ] && [ ${KEEP_RUNNING} -eq 1 ] ; then
		echo "SCRIPT: ---------------------------------- Unison \"$EXECUTER\" execution! ---------------------------------- "
		unison -auto -batch "$DIR_MOUNT_SYNC_HOST" "$DIR_MOUNT_SYNC_GUEST"
		echo "SCRIPT: ----------------------------------------------------------------------------------------------------- "
	fi
}

# Note: Fica monitorando a pasta e em caso de mudanças (pastas e arquivos) dispara a sincronia! By Questor
inotifywait_simult() {
	DIR_MOUNT_SYNC=$1
	while inotifywait -r -e modify,move,create,delete "$DIR_MOUNT_SYNC" && [ ${KEEP_RUNNING} -eq 1 ] ; do
		if [ -d "${DIR_MOUNT_SYNC_GUEST}/SYNC_CTRL_OFF" ] || [ -d "${DIR_MOUNT_SYNC_HOST}/SYNC_CTRL_OFF" ] ; then
			KEEP_RUNNING=0
			echo "SCRIPT: End of synchronization to the directory: \"$DIR_MOUNT_SYNC\" "
			break
		fi
		unison_excuter "inotifywait"
	done
}

# Note: Permite digitar um comando para sair do script! By Questor
script_quit() {
	count=0
	commandValue=''
	while [ ${KEEP_RUNNING} -eq 1 ] ; do 
		if [ "$commandValue" = "quit" ]; then
			echo "SCRIPT: Trying to quit! "
			KEEP_RUNNING=0
			mkdir -p "${DIR_MOUNT_SYNC_GUEST}/SYNC_CTRL_OFF"
			mkdir -p "${DIR_MOUNT_SYNC_HOST}/SYNC_CTRL_OFF"
			break
		fi
		read commandValue
	done
	# exit 0
}

# Note: Desmonta o "samba share" do guest! By Questor
unmount_share() {
	if mountpoint -q "$DIR_MOUNT_SYNC_GUEST" ; then
		echo "SCRIPT: Unmounting the network path! "
		sudo umount "$DIR_MOUNT_SYNC_GUEST"
	fi
}

# Note: Monitora se está tudo okay com as pastas, se não estiver encerra o "inotifywait" e o script! By Questor
watchdog_inotifywait() {
	
	while [ ${KEEP_RUNNING} -eq 1 ] ; do 
		if ! [ "$(ls -A $DIR_MOUNT_SYNC_GUEST)" ]; then
			killer_inotifywait
			KEEP_RUNNING=0
		fi
		sleep 1
	done

}

# Note: Executa o "unison" periodicamente para apanhar mudanças feitas pela guest machine! By Questor
get_changes_made_by_guest_machine() {
	
	while [ ${KEEP_RUNNING} -eq 1 ] && ! [ ${GET_CHANGES_MADE_BY_GUEST_MACHINE_INTERVAL} -eq 0 ]; do 
		sleep ${GET_CHANGES_MADE_BY_GUEST_MACHINE_INTERVAL}
		unison_excuter "periodic [${GET_CHANGES_MADE_BY_GUEST_MACHINE_INTERVAL}s]"
	done

}

# Note: ! By Questor
killer_inotifywait() {
	
	PROCESS="inotifywait"
	PIDS=`ps cax | grep $PROCESS | grep -o '^[ ]*[0-9]*'`
	if ! [ -z "$PIDS" ]; then
		echo "The processes \"inotifywait\" were running and so were killed! :| "
		killall inotifywait
	fi
	
}

# Note: Verifica se o share já está montado. Se não estiver o monta! By Questor
if ! mountpoint -q "$DIR_MOUNT_SYNC_GUEST" ; then
	echo "SCRIPT: Trying to mount the network path! "
	# sudo mount -t cifs -o username=brlight,password=brlight,uid=1000,cache=none,auto "$NET_SHARE_GUEST" "$DIR_MOUNT_SYNC_GUEST"
	sudo mount -t cifs -o username="$NET_SHARE_USER",password="$NET_SHARE_PSW",uid=1000,cache=none,auto "$NET_SHARE_GUEST" "$DIR_MOUNT_SYNC_GUEST"
fi

# Note: Dispara a monitoração de multiplas pastas de forma sincrona e verificador de comando para "quit"! By Questor
# Note: "[ $? -eq 0 ]" verifica a saída de "mount"! By Questor
if [ $? -eq 0 ] ; then

	# Note: Permite a sincronização de mudanças que ocorreram quando o script estava desligado! By Questor
	unison_excuter "initial"
	echo " "
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "SCRIPT: Please do not use \"Ctrl+c\"! You will crash your system! Use the command \"quit\" and press Enter! "
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo " "

	# Note: O "script_quit" tem que ser o último, pois caso contrário não apanha o comando do teclado! By Questor
	# Note: Essa estrutura permite a execução simultânea de várias operações! By Questor
	inotifywait_simult "$DIR_MOUNT_SYNC_GUEST" & inotifywait_simult "$DIR_MOUNT_SYNC_HOST" & watchdog_inotifywait & get_changes_made_by_guest_machine & script_quit
else
	echo "SCRIPT: Crap! The directory can not be mounted! :( "
fi

# Note: Faz uma última verificação no serviço "inotifywait"! By Questor
killer_inotifywait

# Note: Tenta deletar a pasta "SYNC_CTRL_OFF" em caso/ou não de falha anterior (guest)! By Questor
if [ -d "${DIR_MOUNT_SYNC_GUEST}/SYNC_CTRL_OFF" ] ; then
	rm -r "${DIR_MOUNT_SYNC_GUEST}/SYNC_CTRL_OFF"
fi

# Note: Tenta deletar a pasta "SYNC_CTRL_OFF" em caso/ou não de falha anterior (host)! By Questor
if [ -d "${DIR_MOUNT_SYNC_HOST}/SYNC_CTRL_OFF" ] ; then
	rm -r "${DIR_MOUNT_SYNC_HOST}/SYNC_CTRL_OFF"
fi

# Note: Tenta desmontar o share caso tenha restado montado! By Questor
unmount_share

echo "SCRIPT: The sync with the host directory is disabled! Script ended! Thanks! :) "

# Note: Tentativa de garantir que nenhum processo reste! By Questor
KEEP_RUNNING=0
exit=0

