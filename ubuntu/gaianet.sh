Version="1.0.1"

packages=(
    curl
    docker-ce
)

# 检查并安装每个包
function init() {
    for pkg in "${packages[@]}"; do
    if dpkg-query -W "$pkg" >/dev/null 2>&1; then
        echo "$pkg installed,skip"
    else
        echo "install  $pkg..."
        sudo apt update
        sudo apt install -y "$pkg"
    fi
done
}



function VadVars(){

     echo "$ALL_SATEA_VARS"

}


function Manual() {
   >.env.sh

   chmod +x .env.sh

   for i in `echo $ALL_SATEA_VARS | tr ',' '\n' `;do

   i_split=`echo $i |tr -d "{" | tr -d "}"`

   read  -p "$i_split ="  i_split_vars

   echo "$i_split=$i_split_vars" >>.env.sh

   done
}



function install(){
     echo "install steps"
    docker run -itd --name gaianet \
    -p 8080:8080 \
    -v $(pwd)/qdrant_storage:/root/gaianet/qdrant/storage:z \
    gaianet/phi-3-mini-instruct-4k_paris:latest

  status

}

function status() {
   max_attempts=20
   attempt=1
   interval=6
    while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt: Checking GaiaNet node status..."
    if docker logs gaianet | grep -q 'The GaiaNet node is started at'; then
        echo "The GaiaNet node has started successfully."
        nodeid
        docker logs gaianet | grep  'The GaiaNet node is started at'
        exit 0
    else
        echo "The GaiaNet node has not started yet. Waiting for $interval seconds..."
        sleep $interval
        attempt=$((attempt + 1))
    fi
done
echo "The GaiaNet node did not start within the given attempts."
exit 1
}

function nodeid(){
     docker exec -it gaianet /root/gaianet/bin/gaianet info
}

function clean(){
     docker stop gaianet
     docker rm gaianet
     docker rmi gaianet/phi-3-mini-instruct-4k_paris
}


function stop(){
     docker stop gaianet
}


function start(){
     docker start gaianet
     status
}


function About() {
echo '   _____    ___       ______   ______   ___
  / ___/   /   |     /_  __/  / ____/  /   |
  \__ \   / /| |      / /    / __/    / /| |
 ___/ /  / ___ |     / /    / /___   / ___ |
/____/  /_/  |_|    /_/    /_____/  /_/  |_|'

echo
echo -e "\xF0\x9F\x9A\x80 Satea Node Installer
Website: https://www.satea.io/
Twitter: https://x.com/SateaLabs
Discord: https://discord.com/invite/satea
Gitbook: https://satea.gitbook.io/satea
Version: $Version
Introduction: Satea is a DePINFI aggregator dedicated to breaking down the traditional barriers that limits access to computing resources.  "
echo""
}





case $1 in

install)

  if [ "$2" = "--auto" ]
  then
     echo "-> Automatic mode, please ensure that ALL SATEA_VARS(`VadVars`) have been replaced !"
          sleep 3
     install
    else
      echo "Unrecognized variable(`VadVars`) being replaced, manual mode"
      Manual
      . .env.sh
      install


    fi
  ;;

vars)
 #展示变量
VadVars

  ;;

clean)
clean
  ;;

stop)
stop

  ;;
start)
start

  ;;

nodeid)
nodeid
  ;;

init)
init
  ;;

**)
 About
  echo "Flag:
  install              Install gaianet with manual mode,  If carrying the --auto parameter, start Automatic mode
  init                 Install Dependent packages
  stop                 Stop all gaianet
  start                Start all gaianet
  nodeid               Show your node_id
  clean                Remove the gaianet from your server"
  ;;
esac
