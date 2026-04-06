# Elimina todos los componentes descargados por kubernetes 
# Se espera que sea usado despues del Install.sh

#!/bin/bash
helm list
helm uninstall application
sleep 15
helm uninstall databases
sleep 60
helm uninstall bootstrap