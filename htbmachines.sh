#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo ....${endColour}\n"
  tput cnorm && exit 1 
}

#CTRL_C
trap ctrl_c INT

#Variables Globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de máquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por dificultad de la máquina --> ${endColour}${greenColour} (${greenColour}Fácil${endColour},${blueColour} Media${endColour},${yellowColour} Dicícil${endColour},${redColour} Insane) ${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por sistema operativo --> ${endColour}${greenColour} (Windows, Linux) ${endColour}"
  echo -e "\t${purpleColour}s)${endColour}${grayColour} Buscar por Skill ${endColour}${blueColour}( la skill se debe especificar con doble '\"' ej: ${endColour}${greenColour}./htbmcahines.sh -s \"Active Directoy\") ${endColour}"
  echo -e "\t${purpleColour}c)${endColour}${grayColour} Buscar por Certificado para el que te prepara ${endColour}"
  echo -e "${purpleColour}    -o -d)${endColour}${grayColour} Buscar a la vez por sistema operativo y dificultad  --> ${endColour}${yellowColour}ej: ./htbmachines.sh -o Linux -d Fácil ${endColour}"
  echo -e "${purpleColour}    -o -c)${endColour}${grayColour} Buscar a la vez por sistema operativo y certificado --> ${endColour}${yellowColour}ej: ./htbmachines.sh -o Linux -c OSCP ${endColour}"
  echo -e "${purpleColour}    -o -s)${endColour}${grayColour} Buscar a la vez por sistema operativo y skill       --> ${endColour}${yellowColour}ej: ./htbmachines.sh -o Linux -s AutoPwn ${endColour}"
  echo -e "${purpleColour}    -d -c)${endColour}${grayColour} Buscar a la vez por dificultad y certificado        --> ${endColour}${yellowColour}ej: ./htbmachines.sh -d Fácil -c eWPT ${endColour}"
  echo -e "${purpleColour}    -d -s)${endColour}${grayColour} Buscar a la vez por dificultad y la skill           --> ${endColour}${yellowColour}ej: ./htbmachines.sh -d Fácil -s AutoPwn ${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener link de resolución de la máquina en YOUTUBE${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endColour}\n"
}

function updateFiles(){
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
      curl -s $main_url >bundle.js
      js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados${endColour}"
    tput cnorm
  else
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}"
    curl -s $main_url >bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
  
    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizaciones, lo tines todo al día ;)${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Se han encontrado actualizaciones disponibles${endColour}"
      sleep 1

      rm bundle.js && mv bundle_temp.js bundle.js
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los ficheros han sido actualizados${enddColour}"
    fi

    tput cnorm
  fi
}

function searchMachine(){
  machineName="$1"

  machineName_checker="$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
  
  if [ "$machineName_checker" ]; then

    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la máquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"
   
    echo -e  "${yellowColour}$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')${endColour}"
  else
   echo -e "\n${redColour}[!] La máquina no existe${endcolour}\n"
  fi
}

function searchIP(){
  ipAddress="$1"
 
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  
  if [ "$machineName" ]; then
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} La máquina correspondiente para la IP${endColour}${blueColour} $ipAddress${endColour}${grayColour} es${endColour}${purpleColour} $machineName${endColour}"
  else
  echo -e "\n${redColour}[!] La dirección IP proporcionada no existe${endColour}"
  fi
}

function getYoutubeLink(){

  machineName="$1"

  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"  
  if [ "$youtubeLink" ]; then 
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} El tutorial para esta máquina está en el siguinte enlace:${endColour}${blueColour} $youtubeLink${endColour}"
  else
  echo -e "\n${redColour}[!] El nombre proporcionado no es correcto ó la máquina no existe${endColour}" 
  fi
}

function getMachinesDifficulty(){
  difficulty="$1"

  results_check="$(cat bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ','| column)"
  
  if [ "$difficulty" == "Fácil" ]; then 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando máquinas de dificultad${endColour}${greenColour} $difficulty${endColour}${greenColour}:${endColour}\n"
    colores="$(cat bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    echo -e "${greenColour}$colores${endColour}"
  elif [ "$difficulty" == "Media" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando máquinas de dificultad${endColour}${blueColour} $difficulty${endColour}${blueColour}:${endColour}\n"
    colores="$(cat bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    echo -e "${blueColour}$colores${endColour}"
  elif [ "$difficulty" == "Difícil" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando máquinas de dificultad${endColour}${yellowColour} $difficulty${endColour}${yellowColour}:${endColour}\n"
    colores="$(cat bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    echo -e "${yellowColour}$colores${endColour}"
  elif [ "$difficulty" == "Insane" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando máquinas de dificultad${endColour}${redColour} $difficulty${endColour}${redColour}:${endColour}\n"
    colores="$(cat bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    echo -e "${redColour}$colores${endColour}"

  else
  echo -e "\n${redColour}[!] La dificultada no existe. Escoja una de las siguientes.${endColour}\n\n${greenColour}Fácil${endColour},${blueColour} Media${endColour},${yellowColour} Difícil${endColour},${redColour} Insane${endColour}"
  fi
}

function getOSMachines(){
  os="$1"
  
  os_check="$(cat bundle.js | grep -i "so: \"$1\"" -B5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  
  if [ "$os" == "Linux" ]; then
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Listando máquinas con sistema operativo${endColour}${purpleColour} $os${endColour}\n"
    echo -e "${purpleColour}$(cat bundle.js | grep -i "so: \"$1\"" -B5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
  elif [ "$os" == "Windows" ]; then
    echo -e "\n${yellowColour}[*]${endColour}${grayColour} Listando máquinas conn sisteema operativo${endColour}${turquoiseColour} $os${endColour}\n"
    echo -e "${turquoiseColour}$(cat bundle.js | grep -i "so: \"$1\"" -B5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
  else
    echo -e "\n${redColour}[!] El sistema operativo no existe, escoja uno  de los siguientes:${endColour}${blueColour}  Linux, Windows${endColour}"
  fi

}

function getOSDifficultyMachines(){
  difficulty="$1"
  os="$2"
  
  check_results="$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

if [ "$check_results" ] && [ "$difficulty" == "Fácil" ]; then
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificultad${endColour}${greenColour} $difficulty${endColour}${grayColour} que tengan sistema operativo${endColour}${purpleColour} $os${endColour}${grayColour}:${endColour}\n"
  echo -e "${greenColour}$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
elif [ "$check_results" ] && [ "$difficulty" == "Media" ]; then
 echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificultad${endColour}${blueColour} $difficulty${endColour}${grayColour} que tengan sistema operativo${endColour}${purpleColour} $os${endColour}${grayColour}:${endColour}\n"
  echo -e "${blueColour}$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
elif [ "$check_results" ] && [ "$difficulty" == "Difícil" ]; then
 echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificultad${endColour}${yellowColour} $difficulty${endColour}${grayColour} que tengan sistema operativo${endColour}${purpleColour} $os${endColour}${grayColour}:${endColour}\n"
  echo -e "${yellowColour}$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
elif [ "$check_results" ] && [ "$difficulty" == "Insane" ]; then
 echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificultad${endColour}${redColour} $difficulty${endColour}${grayColour} que tengan sistema operativo${endColour}${purpleColour} $os${endColour}${grayColour}:${endColour}\n"
  echo -e "${redColour}$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
else
echo -e "\n${redColour}[!] La selección no existe o es incorrecta.${endColour}"
echo -e "\n${yellowColour}[+]${endColour}${greenColour} Mostrando opciones disponibles:\n${endColour}${grayColour} \n\t-o: Linux, Windows${endColour}${grayColour} \n\t-d: ${greenColour}Fácil,${endColour} ${blueColour}Media,${endColour}${yellowColour} Difícil,${endColour} ${redColour}Insane${endColour}"

fi
}

function getSkill(){
skill="$1"

check_skill=$(cat bundle.js | grep  "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)

  if [ "$check_skill" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con la skill${endColour}${yellowColour} $skill${endColour}${grayColour}:${endColour}\n"
    echo -e "${blueColour}$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
  else
    echo -e "\n${redColour}[!] No se ha detectado la Skill $skill${endColour}"
  fi
}

function getCertificate(){
  certificate="$1"

  check_certificate=$(cat bundle.js | grep "$certificate" -i -B 7 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)
if [ "$check_certificate" ]; then 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando máquinas con certificado${endColour}${blueColour} $certificate${endColour}${grayColour}:${endColour}"
    echo -e "\n${purpleColour}$(cat bundle.js | grep "$certificate" -i -B 7 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
  else
    echo -e "\n${redColour}[!] No se han encortado máquinas para el certificado indicado $certificate${endColour}"
fi
}

function getOSCertificate(){
  os="$1"
  certificate="$2"

  check_OSCertificate="$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep -i "$certificate" -C 9 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$check_OSCertificate" ] && [ "$os" == "Windows" ]  ; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas para el SO${endColour}${blueColour} $os${endColour}${grayColour} y el certificado${endColour}${greenColour} $certificate${endColour}${grayColour}:${endColour}"
    echo -e "${turquoiseColour}\n$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep -i "$certificate" -C 9 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
  elif [ "$check_OSCertificate" ] && [ "$os" == "windows" ]  ; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas para el SO${endColour}${blueColour} $os${endColour}${grayColour} y el certificado${endColour}${greenColour} $certificate${endColour}${grayColour}:${endColour}"
    echo -e "${turquoiseColour}\n$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep -i "$certificate" -C 9 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"

  elif [ "$check_OSCertificate" ] && [ "$os" == "Linux" ]; then
   echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas para el SO${endColour}${blueColour} $os${endColour}${grayColour} y el certificado${endColour}${greenColour} $certificate${endColour}${grayColour}:${endColour}"
    echo -e "${yellowColour}\n$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep -i "$certificate" -C 9 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
     elif [ "$check_OSCertificate" ] && [ "$os" == "linux" ]; then
   echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas para el SO${endColour}${blueColour} $os${endColour}${grayColour} y el certificado${endColour}${greenColour} $certificate${endColour}${grayColour}:${endColour}"
    echo -e "${yellowColour}\n$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep -i "$certificate" -C 9 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"

  else
    echo -e "\n${redColour}[!] No hay máquinas con el sistema operativo ${blueColour}$os${endColour}${redColour} o el certificado${endColour}${greenColour} $certificate${endColour}${redColour} no existe${endColour}"
  fi

}

function getDifficultyCertificate(){
  difficulty="$1"
  certificate="$2"

 check_DifficultyCertificate=$(cat bundle.js | grep -i "dificultad: \"$difficulty\"" -C 7 | grep -i $certificate -B 9 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)

  if [ "$check_DifficultyCertificate" ] && [ "$difficulty" == "Fácil" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificultad${endColour}${blueColour} $difficulty${endColour}${grayColour} y certificado${endColour}${yellowColour} $certificate${endColour}"
    echo -e "\n${greenColour}$(cat bundle.js | grep  "dificultad: \"$difficulty\"" -C 7 | grep -i $certificate -B 9 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
  elif [ "$check_DifficultyCertificate" ] && [ "$difficulty" == "Media" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificultad${endColour}${blueColour} $difficulty${endColour}${grayColour} y certificado${endColour}${yellowColour} $certificate${endColour}"
     echo -e "\n${blueColour}$(cat bundle.js | grep  "dificultad: \"$difficulty\"" -C 7 | grep -i $certificate -B 9 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
  elif [ "$check_DifficultyCertificate" ] && [ "$difficulty" == "Difícil" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificultad${endColour}${blueColour} $difficulty${endColour}${grayColour} y certificado${endColour}${yellowColour} $certificate${endColour}"
     echo -e "\n${yellowColour}$(cat bundle.js | grep  "dificultad: \"$difficulty\"" -C 7 | grep -i $certificate -B 9 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
  elif [ "$check_DifficultyCertificate" ] && [ "$difficulty" == "Insane" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificultad${endColour}${blueColour} $difficulty${endColour}${grayColour} y certificado${endColour}${yellowColour} $certificate${endColour}"
     echo -e "\n${redColour}$(cat bundle.js | grep  "dificultad: \"$difficulty\"" -C 7 | grep -i $certificate -B 9 | grep "name: " |grep -v "Return" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
   else
  echo -e "\n${redColour}[!] No se han detectado máquinas con los parametros${endColour}${blueColour} $difficulty${endColour}${redColour} y${endColour}${yellowColour} $certificate${endColour}"
  fi
}

function getDifficultySkill(){
  difficulty="$1"
  skill="$2"

  check_DifficultySkill=$(cat bundle.js | grep -i "$difficulty" -C 5 | grep -i "skill" -B 7 | grep -i "$skill" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)
if [ "$check_DifficultySkill" ] && [ "$difficulty" == "Fácil" ]; then 
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificutltad${endColour}${greenColour} $difficulty${endColour}${grayColour} y skill${endColour}${purpleColour} $skill${endColour}"
  echo -e "\n${greenColour}$(cat bundle.js | grep -i "$difficulty" -C 5 | grep -i "skill" -B 7 | grep -i "$skill" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
elif [ "$check_DifficultySkill" ] && [ "$difficulty" == "Media" ]; then 
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificutltad${endColour}${blueColour} $difficulty${endColour}${grayColour} y skill${endColour}${purpleColour} $skill${endColour}"
  echo -e "\n${blueColour}$(cat bundle.js | grep -i "$difficulty" -C 5 | grep -i "skill" -B 7 | grep -i "$skill" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
elif [ "$check_DifficultySkill" ] && [ "$difficulty" == "Difícil" ]; then 
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificutltad${endColour}${yellowColour} $difficulty${endColour}${grayColour} y skill${endColour}${purpleColour} $skill${endColour}"
  echo -e "\n${yellowColour}$(cat bundle.js | grep -i "$difficulty" -C 5 | grep -i "skill" -B 7 | grep -i "$skill" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
elif [ "$check_DifficultySkill" ] && [ "$difficulty" == "Insane" ]; then 
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con dificutltad${endColour}${redColour} $difficulty${endColour}${grayColour} y skill${endColour}${purpleColour} $skill${endColour}"
  echo -e "\n${redColour}$(cat bundle.js | grep -i "$difficulty" -C 5 | grep -i "skill" -B 7 | grep -i "$skill" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
else 
  echo -e "\n${redColour}[!] No se han encontrado máquinas con la dificultad${endColour}${yellowColour} $difficulty${endColour}${redColour} y la skill${endColour}${yellowColour} $skill${endColour}"
fi
}

function getOSSkill(){
  os="$1"
  skill="$2"

  check_OSSkill=$(cat bundle.js | grep -i "so: \"$os\"" -C 5 | grep "skill" -B 7 | grep -i "$skill" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)
if [ "$check_OSSkill" ] && [ "$os" == "Windows" ] || [ "$os" == "windows" ]; then
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con sistema operativo${endColour}${blueColour} $os${endColour}${grayColour} y skill${endColour}${purpleColour} $skill${endColour}"
  echo -e "\n${blueColour}$(cat bundle.js | grep -i "so: \"$os\"" -C 5 | grep -i "skill" -B 7 | grep -i "$skill" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
elif [ "$check_OSSkill" ] && [ "$os" == "Linux" ]; then
   echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con sistema operativo${endColour}${greenColour} $os${endColour}${grayColour} y skill${endColour}${purpleColour} $skill${endColour}"
  echo -e "\n${greenColour}$(cat bundle.js | grep -i "so: \"$os\"" -C 5 | grep -i "skill" -B 7 | grep -i "$skill" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
else
 echo -e "\n${redColour}[!] No se han encontrado máquinas para el sistema operativo${endColour}${yellowColour} $os${endColour}${redColour} y la skill${endColour}${yellowColour} $skill${endColour}" 
fi

}

#Indicadores
declare -i parameter_counter=0

# Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0
declare -i chivato_certificate=0
declare -i chivato_skill=0

while getopts "m:ui:y:o:s:c:d:h" arg ; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
    s) skill="$OPTARG"; chivato_skill=1; let parameter_counter+=7;;
    c) certificate="$OPTARG"; chivato_certificate=1; let parameter_counter+=8;;
    h) ;;
  esac 
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then 
  getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os
elif [ $parameter_counter -eq 7 ]; then
  getSkill "$skill"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  getOSDifficultyMachines $difficulty $os
elif [ $chivato_os -eq 1 ] && [ $chivato_certificate -eq 1 ]; then
  getOSCertificate $os $certificate
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_certificate -eq 1 ]; then
  getDifficultyCertificate $difficulty $certificate
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_skill -eq 1 ]; then
  getDifficultySkill $difficulty $skill
elif [ $chivato_os -eq 1 ] && [ $chivato_skill -eq 1 ]; then
  getOSSkill $os $skill
elif [ $parameter_counter -eq 8 ]; then
  getCertificate $certificate
else
  helpPanel
fi
