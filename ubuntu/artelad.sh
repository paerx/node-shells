Version="1.0.1"

# 定义要检查的包列表
packages=(
      curl \
      build-essential \
      git \
      wget \
      jq \
      make \
      gcc \
      nano 
      tmux 
      htop \
      pkg-config \
      libssl-dev \
      libleveldb-dev \
      tar \
      clang \
      bsdmainutils \
      ncdu \
      unzip \
      libleveldb-dev \
      lz4 \
      snapd
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
    if command -v pm2 &> /dev/null
then
    echo "pm2 已安装，跳过安装步骤"
else
    echo "pm2 未安装，开始安装"
    apt update
    apt install npm -y
    npm install -g n
    n latest
    hash -r

    npm install pm2@latest -g
fi
if command -v go >/dev/null 2>&1; then
    echo "go 已安装，跳过安装步骤。"
else
    echo "下载并安装 Go..."
    wget -c https://golang.org/dl/go1.22.4.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

fi
}





ALL_SATEA_VARS="username"



username={{SATEA_VARS_username}}


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
    # 安装所有二进制文件
    cd $HOME
    git clone https://github.com/artela-network/artela
    cd artela
    git checkout v0.4.7-rc7-fix-execution 
    make install
    
    cd $HOME
    wget https://github.com/artela-network/artela/releases/download/v0.4.7-rc7-fix-execution/artelad_0.4.7_rc7_fix_execution_Linux_amd64.tar.gz
    tar -xvf artelad_0.4.7_rc7_fix_execution_Linux_amd64.tar.gz
    mkdir libs
    mv $HOME/libaspect_wasm_instrument.so $HOME/libs/
    mv $HOME/artelad /usr/local/bin/
    echo 'export LD_LIBRARY_PATH=$HOME/libs:$LD_LIBRARY_PATH' >> ~/.bash_profile
    cd
    . .bash_profile
    

    # 配置artelad
    artelad config chain-id artela_11822-1
    artelad init "$username" --chain-id artela_11822-1
    artelad config node tcp://localhost:3457



    # 获取初始文件和地址簿
    curl -L https://snapshots.dadunode.com/artela/genesis.json > $HOME/.artelad/config/genesis.json
    curl -L https://snapshots.dadunode.com/artela/addrbook.json > $HOME/.artelad/config/addrbook.json

    # 配置节点
    SEEDS=""
    PEERS="ca8bce647088a12bc030971fbcce88ea7ffdac50@84.247.153.99:26656,a3501b87757ad6515d73e99c6d60987130b74185@85.239.235.104:3456,2c62fb73027022e0e4dcbdb5b54a9b9219c9b0c1@51.255.228.103:26687,fbe01325237dc6338c90ddee0134f3af0378141b@158.220.88.66:3456,fde2881b06a44246a893f37ecb710020e8b973d1@158.220.84.64:3456,12d057b98ecf7a24d0979c0fba2f341d28973005@116.202.162.188:10656,9e2fbfc4b32a1b013e53f3fc9b45638f4cddee36@47.254.66.177:26656,92d95c7133275573af25a2454283ebf26966b188@167.235.178.134:27856,2dd98f91eaea966b023edbc88aa23c7dfa1f733a@158.220.99.30:26680"
    sed -i 's|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.artelad/config/config.toml

    # 配置裁剪
    sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.artelad/config/app.toml
    sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.artelad/config/app.toml
    sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"0\"/" $HOME/.artelad/config/app.toml
    sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" $HOME/.artelad/config/app.toml
    sed -i -e 's/max_num_inbound_peers = 40/max_num_inbound_peers = 100/' -e 's/max_num_outbound_peers = 10/max_num_outbound_peers = 100/' $HOME/.artelad/config/config.toml

    # 配置端口
    node_address="tcp://localhost:3457"
    sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:3458\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:3457\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:3460\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:3456\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":3466\"%" $HOME/.artelad/config/config.toml
    sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:3417\"%; s%^address = \":8080\"%address = \":3480\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:3490\"%; s%^address = \"localhost:9091\"%address = \"0.0.0.0:3491\"%; s%:8545%:3445%; s%:8546%:3446%; s%:6065%:3465%" $HOME/.artelad/config/app.toml
    echo "export Artela_RPC_PORT=$node_address" >> $HOME/.bash_profile
    . $HOME/.bash_profile   

    pm2 start artelad -- start && pm2 save && pm2 startup
    
    artelad tendermint unsafe-reset-all --home $HOME/.artelad --keep-addr-book
    echo "导入快照。。。。"
    curl https://snapshots-testnet.nodejumper.io/artela-testnet/artela-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.artelad
    #lz4 -dc artela-testnet_latest.tar.lz4 | tar -x -C $HOME/.artelad
  

    pm2 restart artelad


}

function create_validator(){
  username=`cat .artelad/config/config.toml |grep moniker |awk -F'"' '{print $2}'`
  artelad tx staking create-validator \
      --amount="1000000000000000000uart" \
      --pubkey=$(artelad tendermint show-validator) \
      --moniker="$username" \
      --commission-rate="0.10" \
      --commission-max-rate="0.20" \
      --commission-max-change-rate="0.01" \
      --min-self-delegation="1" \
      --gas="200000" \
      --chain-id=artela_11822-1 \
      --from=$(artelad keys list |grep name |awk '{print $2}') \
      -y
}

function create_wallet(){
  artelad config keyring-backend file
  wallet_name=`cat .artelad/config/config.toml |grep moniker |awk -F'"' '{print $2}'`
  artelad keys add $wallet_name 2>&1 |tee $wallet_name.txt
}

function log(){
  pm2 logs artelad
}

function height(){
  artelad status | jq .SyncInfo.latest_block_height
}

function restart(){
  pm2 restart artelad
}

function balances(){
  wallet_name=`cat .artelad/config/config.toml |grep moniker |awk -F'"' '{print $2}'`
  artelad q bank balances $(artelad keys show $wallet_name -a)
}

function address(){
  wallet_name=`cat .artelad/config/config.toml |grep moniker |awk -F'"' '{print $2}'`
  artelad keys show $wallet_name -a
}

function Val_address(){
  wallet_name=`cat .artelad/config/config.toml |grep moniker |awk -F'"' '{print $2}'`
  artelad debug addr $(artelad keys show $wallet_name -a)
}
function import_key(){
  wallet_name=`cat .artelad/config/config.toml |grep moniker |awk -F'"' '{print $2}'`
  artelad config keyring-backend file
  artelad keys add  $wallet_name --recover
}
function clean(){
  pm2 stop artelad && pm2 delete artelad && pm2 save
  rm -rf artela
  rm -rf $HOME/.artelad
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
create_validator)
create_validator
  ;;
Val_address)
Val_address
  ;;
address)
address
  ;;
balances)
balances
  ;;
restart)
restart
  ;;
height)
height
  ;;
log)
log
  ;;
init)
init
  ;;
create_wallet)
create_wallet
  ;;
import_wallet)
import_wallet
  ;;
**)

 #定义帮助信息 例子
 About
  echo "Flag:
  install              Install artela with manual mode,  If carrying the --auto parameter, start Automatic mode
  init                 Install Dependent packages
  log                  Show the logs of the artela service
  clean                Remove the artela from your server
  height               View current height
  create_wallet        Create a wallet
  address              show your wallet address
  balances             show your balances
  Val_address          show your validator address
  import_wallet        import your wallet"
  ;;
esac
