![Static Badge](https://img.shields.io/badge/status-stable-green) ![Static Badge](https://img.shields.io/badge/version-0.1-blue)

# Modo de creación de instantáneas.
El script se ejecuta sobre Linux. Permite hacer un backup incremental diario de una carpeta específica. Para la versión subida, la carpeta será:

    /mnt/e/Bunker

El script permite crear en una carpeta `Snapshots` las instantáneas del día actual. Estas serán incrementales usando el comando `tar` por lo que la primer instantánea contendrá todos los archivos y las que le continúen, contendrán solo las modificaciones. Por esta funcionalidad, se requiere hacer uso de un archivo `.snar` que es el archivo que mantendrá la información de las instantáneas que se van creando.

Al momento de iniciar un nuevo día, el script detecta que existe un archivo `.snar` que no corresponde con el día actual, entonces preguntará si se desea hacer un backup de todas las instantáneas que existan. Si se responde con una afirmación, se creará un archivo `.tgz` que contiene todas las instantáneas correspondientes. Este archivo que se crea llevará el mismo nombre que el archivo `.snar`.

Finalmente, si se realizó la copia de seguridad, la carpeta `Snapshots` será vaciada y se preguntará si es momento de realizar una instantánea del día actual.


# Modo de restauración
Como se mencionó anteriormente, las copias de seguridad de las instantáneas de un día completo se van comprimiendo en una carpeta, esta misma tendrá el nombre `Backups` y se sitúa en la misma ubicación del script. Al momento de requerir restaurar una copia de seguridad, se le deberá pasar como argumento el string `restore`.

En este modo, se solicitará el nombre del archivo que se desea restaurar. Este mismo deberá existir en la carpeta `Backups`, y se deberá escribir el nombre junto con su extensión (que será `.tgz`). Finalmente, el script descomprime el mismo en la carpeta `Archivos`.

# Mejoras
- [ ] Posibilidad de cifrar las copias de seguridad.