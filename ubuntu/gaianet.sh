Version="1.0.1"

# 定义要检查的包列表
packages=(
    curl
    wget
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





##显示需要接收的变量
function VadVars(){
     echo "$ALL_SATEA_VARS"
}

#手动模式下 解析并填入变量的函数
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
     cd
     curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
     export PATH="$HOME/gaianet/bin:$PATH"
     gaianet init
     gaianet start
     gaianet info
}    

function nodeid(){
     gaianet info
}

function clean(){
     curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/uninstall.sh' | bash
}

function upgrade(){
     curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --upgrade

}

function stop(){
     gaianet stop
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

     #这里使用自动模式下的 安装 函数
     install

    else
      echo "Unrecognized variable(`VadVars`) being replaced, manual mode"

      #手动模式 使用Manual 获取用户输入的变量

      Manual      #获取用户输入的变量
      . .env.sh   #导入变量

      #其他安装函数
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

upgrade)
upgrade

  ;;

nodeid)
nodeid
  ;;
init)
init
  ;;

**)

 #定义帮助信息 例子
 About
  echo "Flag:
  install              Install gaianet with manual mode,  If carrying the --auto parameter, start Automatic mode
  init                 Install Dependent packages
  stop                 Stop all gaianet
  nodeid               show your node_id
  upgrade              Upgrade an existing installation of gaianet
  clean                Remove the gaianet from your server"
  ;;
esac
