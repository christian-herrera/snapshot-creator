#!/bin/bash
#Version 0.1

# Carpeta que se realizara el Backup
DIR_TO_BK="/mnt/e/Bunker"



# Variables Globales
NOW_YMDHM=$(date +%Y_%m_%d_%H_%M_%S)
NOW_YMD=$(date +%Y_%m_%d)
NOW_DIALOG=$(date +%Y/%m/%d) 
DIR_BACKUPS=$(pwd)


# ==============================================================================> FUNCIONES
MSJE_BIENVENIDA () {
    dialog  --clear --colors \
            --title " Bienvenido " \
            --msgbox "Este script le permitira crear instantaneas de una carpeta especifica. Si se le pasa el argumento \Z4restore\Zn se iniciara como script de restauracion, con la posibilidad de restarurar un backup completo." \
            8 60
}


MSJE_RESTAURACION() {
    dialog  --clear --colors \
            --title " Modo Restauracion " \
            --yesno "Se realizara la restauracion de un archivo Backup ubicado en la carpeta Backups. Desea proceder?" \
            8 60

    if [[ $? -eq 0 ]]; then        
        name=$(dialog   --clear --colors --stdout \
                        --title " Seleccion de Archivo " \
                        --inputbox "Ingresa el nombre (con su extension) del archivo que desea restarurar. Este archivo debera existir en la carpeta \Z4./Backups/\Zn\n" \
                        8 60)
        
        # Verifico si existe
        if [[ -e "Backups/$name" ]]; then
            TAM=$(du -sh Backups/$name | awk '{print $1}')

            dialog	--clear \
				--colors \
				--title " Confirmacion " \
				--yesno "Se procedera a restaurar el Backup con el nombre:\n\n   \Z1$name\Zn \Zb\Z4[$TAM]\Zn\n\nDesea proceder?" 0 0

            if [[ $? -eq 0 ]]; then
                dialog 	--clear \
                        --timeout 1 \
                        --colors \
                        --title " Estado " \
                        --msgbox "Restaurando las instantaneas contenidas en el backup \Z1$name\Zn.\n\nPor favor espere, este proceso puede demorar varios minutos ya que el backup es de \Z4${TAM}b\Zn." 0 0

                # Creo la carpeta donde ubicare los archivos restaurados
                mkdir -p Archivos &> /dev/null

                # Obtengo el nombre del archivo sin la extension ni la ruta
                BK_NAME=$(basename $name .tgz)

                # Voy a la carpeta, descomprimo el backup que contiene las instantaneas
                # luego, descomprimo cada una de las instantaneas
                cd Archivos
                tar -xf ../Backups/$name -C . && \
                find . -type f -name '*.tgz' -exec tar -xGf {} -C . \; && \
                rm -r $BK_NAME
                cd ..

                dialog 	--clear \
                        --title " Resultado " \
                        --msgbox "El backup fue restaurado!. El Script finalizara al presionar 'Ok'" \
                        6 65
            fi
        else
            dialog  --clear \
                    --title " Error " \
                    --msgbox "El archivo no se puede encontrar. Ejecute nuevamente el script y vuelva a cargar el nombre del archivo." \
                    8 65
        fi
        
		clear
    else
       clear 
    fi
}



CREAR_SNAPSHOT() {
	LIST_EXCLUDE="$DIR_BACKUPS/exclude_list.txt"

	# Defino la ruta y nombre de la carpeta que se quiere resguardar
	FOLDER_TO_BK=$(basename $DIR_TO_BK)
	DIR_TO_BK=$(dirname $DIR_TO_BK)


	dialog	--clear --colors --timeout 1 \
			--title "Estado" \
			--msgbox "\Z2El sistema esta creando el Snapshot...\Zn\n\nPor favor espere, esto puede demorar algunos minutos ya que depende del tamaño de los archivos." \
            8 65

	# Me muevo a la carpeta que quiero resguardar, luego genero la instantanea, guardadola en la carpeta de los Snapshots,
	# finalmente, vuelvo al lugar donde estaba.
	cd $DIR_TO_BK
	tar -czf $DIR_BACKUPS/Snapshots/$NOW_YMDHM.tgz -g $DIR_BACKUPS/Snapshots/$NOW_YMD.snar --exclude-from="$LIST_EXCLUDE"  $FOLDER_TO_BK
	cd $DIR_BACKUPS
	
	# Muestro la instantanea que se acaba de crear, junto con su tamaño
	TAM=$(du -sh $DIR_BACKUPS/Snapshots/$NOW_YMDHM.tgz | awk '{print $1}')


	dialog	--clear --colors \
			--title "Resultado" \
			--msgbox "La instantanea se creo con exito!\n\nArchivo: $NOW_YMDHM.tgz \Zb\Z4[$TAM]\Zn" 8 60

	clear
}




CREAR_BACKUP_DE_SNAPSHOTS() {
    mkdir -p $DIR_BACKUPS/Snapshots $DIR_BACKUPS/Backups &> /dev/null

    if [ -n "$(ls -A "$DIR_BACKUPS/Snapshots")" ]; then     # Preg: Existe al menos una instantanea?
        # Pregunto si desea realizar el backup
		dialog	--clear \
				--title "Backup de las Instantaneas" \
				--yesno "Las instantaneas actuales corresponden a una fecha distinta a la de hoy ($NOW_DIALOG). Si continua, se procedera a crear un backup completo de la carpeta donde se encuentran las Snapshots.\n\nDesea continuar?" \
				10 60

		if [[ $? -eq 0 ]]; then # Resp: Ok
			dialog  --clear --colors --timeout 1 \
            		--title " Backup de las Instantaneas " \
            		--msgbox "\Z2El sistema esta realizando el backup...\Zn\n\nPor favor espere, este proceso puede durar varios minutos ya que depende del tamaño de los Snapshots." \
                    8 65

			# Obtengo el nombre del .snar y lo uso para crear el backup, utilizo ese nombre y lo guardo en ./Backups/
			BK_NAME=$(find . -type f -name '*.snar' -exec basename {} .snar \;)

			mv Snapshots $BK_NAME
			tar -czf $DIR_BACKUPS/Backups/$BK_NAME.tgz $BK_NAME && \
			rm -rf $BK_NAME

			mkdir -p $DIR_BACKUPS/Snapshots $DIR_BACKUPS/Backups &> /dev/null

			# Muestro las estadisticas
			TAM=$(du -sh $DIR_BACKUPS/Backups/$BK_NAME.tgz | awk '{print $1}')

			dialog  --clear \
            		--title "Backup de las Instantaneas" \
            		--msgbox "Backup creado con el nombre:\n\n$BK_NAME.tgz [$TAM]" \
                    8 45

			# Creo la primer instantanea del dia (Lo pregunta)
			dialog  --clear \
            		--title "Creacion de Instantaneas" \
            		--yesno "Desea crear la primer instantanea del dia?" \
                    8 45

            if [[ $? -eq 0 ]]; then # Resp: Si
				CREAR_SNAPSHOT
			else                    # Resp: No
				clear
			fi
		else # Resp: No
			clear
		fi
	else # Si no existe alguna instantanea, omito el backup y creo el snapshot
		CREAR_SNAPSHOT
	fi
}



CHECK_DAILY_SNAPSHOT() {
    mkdir -p $DIR_BACKUPS/Snapshots $DIR_BACKUPS/Backups &> /dev/null


    if [ -e "$DIR_BACKUPS/Snapshots/$NOW_YMD.snar" ]; then      # Existe el *.snar
        dialog	--clear \
                --title " Descripcon " \
			    --yesno "Existen las instantaneas para la fecha de hoy ($NOW_DIALOG).\n\nDesea continuar con la creacion de una instantanea?" \
                8 75

        if [[ $? -eq 0 ]]; then # Resp: Ok
            CREAR_SNAPSHOT
        else                    # Resp: Exit
            clear
        fi
    else        # No Existe el *.snar
        CREAR_BACKUP_DE_SNAPSHOTS
    fi
}






# ==============================================================================> MAIN
PAQ_DIALOG=$(which dialog)

if [[ $PAQ_DIALOG = "" ]]; then
    clear
    echo -e "\n[\e[31mERROR\e[0m]: El Script requiere tener instalado el paquete \e[0;32mDialog\e[0m"
    echo -e "\n\nSe recomiendoa instalarlo usando 'apt install dialog'\n"
else
    if [[ $# -eq 0 ]]; then
        MSJE_BIENVENIDA
        CHECK_DAILY_SNAPSHOT
    else
        if [[ $1 == "restore" ]]; then
            MSJE_RESTAURACION
        else
            echo -e "No se recibio un comando valido!\n"
        fi
    fi
fi

#sexit 0