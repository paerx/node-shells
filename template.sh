# 定义要检查的包列表
packages=(
    jq
    curl
    wget
)

# 检查并安装每个包
function installpkg() {
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



##定义脚本变量

#举例： 这个脚本需要依赖  test01 test02 username passwd

#  第一步: 在ALL_SATEA_VARS定义变量 用逗号隔开,方便手动模式下Manual函数解析需要的变量

ALL_SATEA_VARS="test01,test02,username,passwd"

#  第二步: 创建变量 并设置站位符号, 方便自动模式下系统替换变量

test01={{SATEA_VARS_test01}}

test02={{SATEA_VARS_test02}}

username={{SATEA_VARS_username}}

passwd={{SATEA_VARS_passwd}}


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
}




function About() {
echo ' __     _     _____     __     _
/ _\   /_\   /__   \   /__\   /_\
\ \   //_\\    / /\/  /_\    //_\\
_\ \ /  _  \  / /    //__   /  _  \
\__/ \_/ \_/  \/     \__/   \_/ \_/'

echo
echo -e "\xF0\x9F\x9A\x80Satea Node Installer
Website: ​https://www.satea.io/
Twitter: ​https://x.com/SateaLabs
Discord: ​https://discord.com/invite/satea
Gitbook: ​https://satea.gitbook.io/satea
Version: ​V1.0.0
Introduction: Satea is a DePINFI aggregator dedicated to breaking down the traditional barriers that limits access to computing resources.  "
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

check)
 #创建一些用于检查节点的函数

  ;;

vars)
 #展示变量
VadVars

  ;;

clean)
 #创建清楚节点的函数

  ;;

stop)
 #创建停止节点的函数

  ;;

upgrade)
 #创建升级节点的函数


  ;;

  logs)
    #打印节点信息

    ;;


**)

 #定义帮助信息 例子
 About
 echo""
  echo "Flag:
  install              Install Hubble with manual mode,  If carrying the --auto parameter, start Automatic mode
  pkg                  Install Dependent packages
  stop                 Stop all Hubble docker
  up                   Start all Hubble docker
  upgrade              Upgrade an existing installation of Hubble
  logs                 Show the logs of the Hubble service
  clean                Remove the Hubble from your server"
  ;;
esac
