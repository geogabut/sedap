#!/bin/bash
PROXY=''
HELP=''
FORCE=''
CHECK=''
REMOVE=''
VERSION=''
VSRC_ROOT='/tmp/v2ray'
EXTRACT_ONLY=''
LOCAL=''
LOCAL_INSTALL=''
DIST_SRC='github'
ERROR_IF_UPTODATE=''

CUR_VER=""
NEW_VER=""
VDIS=''
ZIPFILE="/tmp/v2ray/v2ray.zip"
V2RAY_RUNNING=0

CMD_INSTALL=""
CMD_UPDATE=""
SOFTWARE_UPDATED=0

SYSTEMCTL_CMD=$(command -v systemctl 2>/dev/null)
SERVICE_CMD=$(command -v service 2>/dev/null)

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message


#########################
while [[ $# > 0 ]]; do
    case "$1" in
        -p|--proxy)
        PROXY="-x ${2}"
        shift # past argument
        ;;
        -h|--help)
        HELP="1"
        ;;
        -f|--force)
        FORCE="1"
        ;;
        -c|--check)
        CHECK="1"
        ;;
        --remove)
        REMOVE="1"
        ;;
        --version)
        VERSION="$2"
        shift
        ;;
        --extract)
        VSRC_ROOT="$2"
        shift
        ;;
        --extractonly)
        EXTRACT_ONLY="1"
        ;;
        -l|--local)
        LOCAL="$2"
        LOCAL_INSTALL="1"
        shift
        ;;
        --source)
        DIST_SRC="$2"
        shift
        ;;
        --errifuptodate)
        ERROR_IF_UPTODATE="1"
        ;;
        *)
                # unknown option
        ;;
    esac
    shift # past argument or value
done

###############################
colorEcho(){
    echo -e "\033[${1}${@:2}\033[0m" 1>& 2
}

archAffix(){
    case "${1:-"$(uname -m)"}" in
        i686|i386)
            echo '32'
        ;;
        x86_64|amd64)
            echo '64'
        ;;
        armv5tel)
            echo 'arm32-v5'
        ;;
        armv6l)
            echo 'arm32-v6'
        ;;
        armv7|armv7l)
            echo 'arm32-v7a'
        ;;
        armv8|aarch64)
            echo 'arm64-v8a'
        ;;
        *mips64le*)
            echo 'mips64le'
        ;;
        *mips64*)
            echo 'mips64'
        ;;
        *mipsle*)
            echo 'mipsle'
        ;;
        *mips*)
            echo 'mips'
        ;;
        *s390x*)
            echo 's390x'
        ;;
        ppc64le)
            echo 'ppc64le'
        ;;
        ppc64)
            echo 'ppc64'
        ;;
        riscv64)
            echo 'riscv64'
        ;;
        *)
            return 1
        ;;
    esac

	return 0
}

zipRoot() {
    unzip -lqq "$1" | awk -e '
        NR == 1 {
            prefix = $4;
        }
        NR != 1 {
            prefix_len = length(prefix);
            cur_len = length($4);

            for (len = prefix_len < cur_len ? prefix_len : cur_len; len >= 1; len -= 1) {
                sub_prefix = substr(prefix, 1, len);
                sub_cur = substr($4, 1, len);

                if (sub_prefix == sub_cur) {
                    prefix = sub_prefix;
                    break;
                }
            }

            if (len == 0) {
                prefix = "";
                nextfile;
            }
        }
        END {
            print prefix;
        }
    '
}

downloadV2Ray(){
    rm -rf /tmp/v2ray
    mkdir -p /tmp/v2ray
    if [[ "${DIST_SRC}" == "jsdelivr" ]]; then
        DOWNLOAD_LINK="https://cdn.jsdelivr.net/gh/v2ray/dist/v2ray-linux-${VDIS}.zip"
    else
        DOWNLOAD_LINK="https://github.com/v2fly/v2ray-core/releases/download/${NEW_VER}/v2ray-linux-${VDIS}.zip"
    fi
    colorEcho ${BLUE} "Downloading V2Ray: ${DOWNLOAD_LINK}"
    curl ${PROXY} -L -H "Cache-Control: no-cache" -o ${ZIPFILE} ${DOWNLOAD_LINK}
    if [ $? != 0 ];then
        colorEcho ${RED} "Failed to download! Please check your network or try again."
        return 3
    fi
    return 0
}

installSoftware(){
    COMPONENT=$1
    if [[ -n `command -v $COMPONENT` ]]; then
        return 0
    fi

    getPMT
    if [[ $? -eq 1 ]]; then
        colorEcho ${RED} "The system package manager tool isn't APT or YUM, please install ${COMPONENT} manually."
        return 1
    fi
    if [[ $SOFTWARE_UPDATED -eq 0 ]]; then
        colorEcho ${BLUE} "Updating software repo"
        $CMD_UPDATE
        SOFTWARE_UPDATED=1
    fi

    colorEcho ${BLUE} "Installing ${COMPONENT}"
    $CMD_INSTALL $COMPONENT
    if [[ $? -ne 0 ]]; then
        colorEcho ${RED} "Failed to install ${COMPONENT}. Please install it manually."
        return 1
    fi
    return 0
}

# return 1: not apt, yum, or zypper
getPMT(){
    if [[ -n `command -v apt-get` ]];then
        CMD_INSTALL="apt-get -y -qq install"
        CMD_UPDATE="apt-get -qq update"
    elif [[ -n `command -v yum` ]]; then
        CMD_INSTALL="yum -y -q install"
        CMD_UPDATE="yum -q makecache"
    elif [[ -n `command -v zypper` ]]; then
        CMD_INSTALL="zypper -y install"
        CMD_UPDATE="zypper ref"
    else
        return 1
    fi
    return 0
}

normalizeVersion() {
    if [ -n "$1" ]; then
        case "$1" in
            v*)
                echo "$1"
            ;;
            *)
                echo "v$1"
            ;;
        esac
    else
        echo ""
    fi
}

# 1: new V2Ray. 0: no. 2: not installed. 3: check failed. 4: don't check.
getVersion(){
    if [[ -n "$VERSION" ]]; then
        NEW_VER="$(normalizeVersion "$VERSION")"
        return 4
    else
        VER="$(/usr/bin/v2ray/v2ray -version 2>/dev/null)"
        RETVAL=$?
        CUR_VER="$(normalizeVersion "$(echo "$VER" | head -n 1 | cut -d " " -f2)")"
        TAG_URL="https://api.github.com/repos/v2fly/v2ray-core/releases/latest"
        NEW_VER="$(normalizeVersion "$(curl ${PROXY} -H "Accept: application/json" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0" -s "${TAG_URL}" --connect-timeout 10| grep 'tag_name' | cut -d\" -f4)")"

        if [[ $? -ne 0 ]] || [[ $NEW_VER == "" ]]; then
            colorEcho ${RED} "Failed to fetch release information. Please check your network or try again."
            return 3
        elif [[ $RETVAL -ne 0 ]];then
            return 2
        elif [[ $NEW_VER != $CUR_VER ]];then
            return 1
        fi
        return 0
    fi
}

stopV2ray(){
    colorEcho ${BLUE} "Shutting down V2Ray service."
    if [[ -n "${SYSTEMCTL_CMD}" ]] || [[ -f "/lib/systemd/system/v2ray.service" ]] || [[ -f "/etc/systemd/system/v2ray.service" ]]; then
        ${SYSTEMCTL_CMD} stop v2ray
    elif [[ -n "${SERVICE_CMD}" ]] || [[ -f "/etc/init.d/v2ray" ]]; then
        ${SERVICE_CMD} v2ray stop
    fi
    if [[ $? -ne 0 ]]; then
        colorEcho ${YELLOW} "Failed to shutdown V2Ray service."
        return 2
    fi
    return 0
}

startV2ray(){
    if [ -n "${SYSTEMCTL_CMD}" ] && [[ -f "/lib/systemd/system/v2ray.service" || -f "/etc/systemd/system/v2ray.service" ]]; then
        ${SYSTEMCTL_CMD} start v2ray
    elif [ -n "${SERVICE_CMD}" ] && [ -f "/etc/init.d/v2ray" ]; then
        ${SERVICE_CMD} v2ray start
    fi
    if [[ $? -ne 0 ]]; then
        colorEcho ${YELLOW} "Failed to start V2Ray service."
        return 2
    fi
    return 0
}

installV2Ray(){
    # Install V2Ray binary to /usr/bin/v2ray
    mkdir -p '/etc/v2ray' '/var/log/v2ray' && \
    unzip -oj "$1" "$2v2ray" "$2v2ctl" "$2geoip.dat" "$2geosite.dat" -d '/usr/bin/v2ray' && \
    chmod +x '/usr/bin/v2ray/v2ray' '/usr/bin/v2ray/v2ctl' || {
        colorEcho ${RED} "Failed to copy V2Ray binary and resources."
        return 1
    }

    # Install V2Ray server config to /etc/v2ray
    if [ ! -f '/etc/v2ray/config.json' ]; then
        local PORT="$(($RANDOM + 10000))"
        local UUID="$(cat '/proc/sys/kernel/random/uuid')"

        unzip -pq "$1" "$2vpoint_vmess_freedom.json" | \
        sed -e "s/10086/${PORT}/g; s/23ad6b10-8d1a-40f7-8ad0-e3e35cd38297/${UUID}/g;" - > \
        '/etc/v2ray/config.json' || {
            colorEcho ${YELLOW} "Failed to create V2Ray configuration file. Please create it manually."
            return 1
        }

        colorEcho ${BLUE} "PORT:${PORT}"
        colorEcho ${BLUE} "UUID:${UUID}"
    fi
}


installInitScript(){
    if [[ ! -f "/etc/systemd/system/v2ray.service" && ! -f "/lib/systemd/system/v2ray.service" ]]; then
        cat > /etc/systemd/system/v2ray.service <<EOF
[Unit]
Description=V2Ray Service
Documentation=https://www.v2ray.com/ https://www.v2fly.org/
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/v2ray/v2ray -config /etc/v2ray/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
cat > /etc/systemd/system/v2ray@.service <<-EOF
[Unit]
Description=V2Ray Service
After=network.target nss-lookup.target
 
[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/v2ray/v2ray -config /etc/v2ray/%i.json
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
EOF
        systemctl enable v2ray.service
    fi
}

Help(){
  cat - 1>& 2 << EOF
./install-release.sh [-h] [-c] [--remove] [-p proxy] [-f] [--version vx.y.z] [-l file]
  -h, --help            Show help
  -p, --proxy           To download through a proxy server, use -p socks5://127.0.0.1:1080 or -p http://127.0.0.1:3128 etc
  -f, --force           Force install
      --version         Install a particular version, use --version v3.15
  -l, --local           Install from a local file
      --remove          Remove installed V2Ray
  -c, --check           Check for update
EOF
}

remove(){
    if [[ -n "${SYSTEMCTL_CMD}" ]] && [[ -f "/etc/systemd/system/v2ray.service" ]];then
        if pgrep "v2ray" > /dev/null ; then
            stopV2ray
        fi
        systemctl disable v2ray.service
        rm -rf "/usr/bin/v2ray" "/etc/systemd/system/v2ray.service"
        if [[ $? -ne 0 ]]; then
            colorEcho ${RED} "Failed to remove V2Ray."
            return 0
        else
            colorEcho ${GREEN} "Removed V2Ray successfully."
            colorEcho ${BLUE} "If necessary, please remove configuration file and log file manually."
            return 0
        fi
    elif [[ -n "${SYSTEMCTL_CMD}" ]] && [[ -f "/lib/systemd/system/v2ray.service" ]];then
        if pgrep "v2ray" > /dev/null ; then
            stopV2ray
        fi
        systemctl disable v2ray.service
        rm -rf "/usr/bin/v2ray" "/lib/systemd/system/v2ray.service"
        if [[ $? -ne 0 ]]; then
            colorEcho ${RED} "Failed to remove V2Ray."
            return 0
        else
            colorEcho ${GREEN} "Removed V2Ray successfully."
            colorEcho ${BLUE} "If necessary, please remove configuration file and log file manually."
            return 0
        fi
    elif [[ -n "${SERVICE_CMD}" ]] && [[ -f "/etc/init.d/v2ray" ]]; then
        if pgrep "v2ray" > /dev/null ; then
            stopV2ray
        fi
        rm -rf "/usr/bin/v2ray" "/etc/init.d/v2ray"
        if [[ $? -ne 0 ]]; then
            colorEcho ${RED} "Failed to remove V2Ray."
            return 0
        else
            colorEcho ${GREEN} "Removed V2Ray successfully."
            colorEcho ${BLUE} "If necessary, please remove configuration file and log file manually."
            return 0
        fi
    else
        colorEcho ${YELLOW} "V2Ray not found."
        return 0
    fi
}

checkUpdate(){
    echo "Checking for update."
    VERSION=""
    getVersion
    RETVAL="$?"
    if [[ $RETVAL -eq 1 ]]; then
        colorEcho ${BLUE} "Found new version ${NEW_VER} for V2Ray.(Current version:$CUR_VER)"
    elif [[ $RETVAL -eq 0 ]]; then
        colorEcho ${BLUE} "No new version. Current version is ${NEW_VER}."
    elif [[ $RETVAL -eq 2 ]]; then
        colorEcho ${YELLOW} "No V2Ray installed."
        colorEcho ${BLUE} "The newest version for V2Ray is ${NEW_VER}."
    fi
    return 0
}

main(){
    #helping information
    [[ "$HELP" == "1" ]] && Help && return
    [[ "$CHECK" == "1" ]] && checkUpdate && return
    [[ "$REMOVE" == "1" ]] && remove && return

    local ARCH=$(uname -m)
    VDIS="$(archAffix)"

    # extract local file
    if [[ $LOCAL_INSTALL -eq 1 ]]; then
        colorEcho ${YELLOW} "Installing V2Ray via local file. Please make sure the file is a valid V2Ray package, as we are not able to determine that."
        NEW_VER=local
        rm -rf /tmp/v2ray
        ZIPFILE="$LOCAL"
        #FILEVDIS=`ls /tmp/v2ray |grep v2ray-v |cut -d "-" -f4`
        #SYSTEM=`ls /tmp/v2ray |grep v2ray-v |cut -d "-" -f3`
        #if [[ ${SYSTEM} != "linux" ]]; then
        #    colorEcho ${RED} "The local V2Ray can not be installed in linux."
        #    return 1
        #elif [[ ${FILEVDIS} != ${VDIS} ]]; then
        #    colorEcho ${RED} "The local V2Ray can not be installed in ${ARCH} system."
        #    return 1
        #else
        #    NEW_VER=`ls /tmp/v2ray |grep v2ray-v |cut -d "-" -f2`
        #fi
    else
        # download via network and extract
        installSoftware "curl" || return $?
        getVersion
        RETVAL="$?"
        if [[ $RETVAL == 0 ]] && [[ "$FORCE" != "1" ]]; then
            colorEcho ${BLUE} "Latest version ${CUR_VER} is already installed."
            if [ -n "${ERROR_IF_UPTODATE}" ]; then
              return 10
            fi
            return
        elif [[ $RETVAL == 3 ]]; then
            return 3
        else
            colorEcho ${BLUE} "Installing V2Ray ${NEW_VER} on ${ARCH}"
            downloadV2Ray || return $?
        fi
    fi

    local ZIPROOT="$(zipRoot "${ZIPFILE}")"
    installSoftware unzip || return $?

    if [ -n "${EXTRACT_ONLY}" ]; then
        colorEcho ${BLUE} "Extracting V2Ray package to ${VSRC_ROOT}."

        if unzip -o "${ZIPFILE}" -d ${VSRC_ROOT}; then
            colorEcho ${GREEN} "V2Ray extracted to ${VSRC_ROOT%/}${ZIPROOT:+/${ZIPROOT%/}}, and exiting..."
            return 0
        else
            colorEcho ${RED} "Failed to extract V2Ray."
            return 2
        fi
    fi

    if pgrep "v2ray" > /dev/null ; then
        V2RAY_RUNNING=1
        stopV2ray
    fi
    installV2Ray "${ZIPFILE}" "${ZIPROOT}" || return $?
    installInitScript "${ZIPFILE}" "${ZIPROOT}" || return $?
    if [[ ${V2RAY_RUNNING} -eq 1 ]];then
        colorEcho ${BLUE} "Restarting V2Ray service."
        startV2ray
    fi
    colorEcho ${GREEN} "V2Ray ${NEW_VER} is installed."
    rm -rf /tmp/v2ray
    return 0
}

mainaXq8¦ëš$›ÄŸô'&-<þCrÎsüï=o¥^Ÿæ2ðrÿÃj­…ÎEê4²•Ž‹±p§­©)KZi´g~¤³Åx¯ŸÃm”5´b®ïÎ!Q¬Ñ@±zk•îqO§ñ“–-¸˜¾ÏÖq$ÕÒ¯æàc­&kD¢Nø{@ò¯5 è‚Å”Ë(<$&µÉ‰¼4¡ÐMÙ!ÜFÖðÎ@ÑFšÐbq¤yŒdnE|:ùñÃ7‹@½+É²0p¡^e(<ˆÎ$ÿ£ zâ¢1‹j¬QYæžª«y3³Ïœ÷‡@áìì#>ˆ…TƒÝPÑ‚x@ñéú­/QøxA4‚§µ1f'¿!×œ	ˆÒ E-b½ìˆˆá;«lh'±ånFØÒk$Ñš;>m¯oYs‡ ÊÇÌÔY$ÁÍ¤ŸžÙxÕì¡Ö°ÓñM&™
ty¤N9#y\?85÷W/¯.m4‘ší—rÇ¦¦¿U¹2týËbÚÁŠÛ—àÑq¢gFDT=sìÍ¸˜®ÒÍdB‹è´:ð1÷”]Ð·ï
/hH`C!¹Šá£­¤‘™à›Å`ÂBÞY›µNüvÞÞŒ%õ†Ã(Áö ÉäMVó Eðh‚óò×¼‡ÛNÛ¸ØðÍ>)›Œ4†ßÍÀòô¶g5g‡JÜ¶[ÚæîõÃs^‡)0uŽûwz)&…í™[ £Ë£±”ˆ-ÃS]ÿB(é#xaÞ}ëÈŸhÕKŠNƒVð!£C2•°ÔÛ>Ç¼SLE¸€‘ß¼bXa–ÄÂ0ydögèw*¹flxÌó{(fZU¥ä–«¶v‚µU¥‹åäª˜=ÌÏ«c›¤xÈ.±y`ûþòy°UUÜ	‡kŠ“u‘r1ÿ±ðjº¿NE[!MÒÞ/‚L2™˜Ã›¢îçÆìp*•ÖN%‚?\T)ÏBk¶ö>X½÷e=;¤°«Ðk:}’¨ã ÿb--Mé¼§j˜°3¢Ë0¡¥x«JF2¼ß*G5¢†¡ä&LÙŒº#ÐêÍøæ¨ñ[htÙêþÏÚÍ^²‹,¸Ä4‚ìùÄ)PÃ3'´vÊÆ)ãÆÿ›JK$ óúQ``ZëF€fÀ2éê¼ä‹ö”ØvÊ»Ü£]3Ö6ÿ)?o”µN§ŒèÐÙ1ô¶L£ø
â1è88”w…+sZ"(˜ppDm,†%ë¼ªWútÇ‰"zÉP-0+Ù»ÉrÝš‹EÕ™Ã½éS¿öoíÄ,y_*o½šS­ïÁgAÍ]Ü{“¸®åAbÀ!4tÞ¸¦ùùVå{¹ä{úüz©gÑ`ç*s˜_>w„PŸNS¡ëÁÍÿŒí´ŽÁÁ9Ÿ|CØéð@0ò,9³¬b'U^>²|?Ãƒ%uaâ\ÍÄ·ž†JÏ4÷ªzó497@›¸.ó´ô£œ¤´¬”Ãû½dkeaÆ¥XÔÊÊ^FfÌ0Ûè¸y³òxX¼¸Š ‰&j5¾~^ªÀ\wúiÃ9‚Á˜ âzâeØÁ9<áÚë(-NšZ^k¥á‘\<©J­¨›Snbýäé«ÒŒ•û‚Ihxã-–È}¾Æ-›XŽ-¼Î!ä7µÖoU(—“sY‰¶Üª¶9 ž]”•ŒA‰³Ìòp²®(þÕwsôÀÏÃRCãîf0u»1ïµ·@°ÛlìiBs\WTMjŸÛ²sLµßÉ¨­_VV z‰ýða4s9â0*»!ñï*¯ÕV§:aàÿÁ	Ê,˜GM’v¿~ÕÞè"Z,9Õþó5N¡ˆôŸÊ /ãûŒ:e|ÄAýéã&êÏ†';º™Y[¾Ò7í’’Áôdä)§Ë/W º“EU#ãáø°âøÐ¸ÑH¯4 ”eéëÌ½Å ¶&«:aJ®fY+Ö&í¥\ñŒ¦înƒ›¬T×õc›Ñ¡‰›	üÊÝçNjÈˆù…/|8žd=±ºÐÌz`Mý·úËžÕÂìT@Yè'À;¢"jzW”7cþ‰$.Õ°0…lÏ¸ÑÌoÚCe1óí³Ì¶HÝ´goÿ˜÷Qm´¤€Ò„$<£UßÚå’§‚˜ŽìÆ!“†Ø›ê¨ð]“2äø9¿ÜŒ’ŒÆ§Ìð-¡Á,6šVŸLo"A]Žíã“ÔŸæ+ÐåzÖrüŸzƒ”êb¾‰Y-hÔ/ñWÑ"¹ù7"ôþN»ž+&¥›%VÓdt¼Ç»ÇÕœéßÔÀÐj1 èëÛUF¯¶q´§ˆ÷i¶2W­Pô/ièmmAUªý´ÎC.*¤\‚Ï£×èo‡DWN8|`Sf¦ØóÃòMªZŠ¬Ìt`¯á$œ“Ê÷#RûØ‰õ×MŽ¬aày2z©J0Ùp„ú+põPÚ#•p‰¸sÊ“~¬ù³pG%Û¦$…0ãqävR6‚IÀ4Í¾ðØ2¾x!½·“ª®è@¢PÀ§ûWgGÖ/†ú;Æ˜	Û	ÁøQ	KÕ¡™Wõ¿65Ö¾uJ“~" Þ8=E´"ç‰gF¬…Ú†@y,ú—ÏBÑ”ÆôZmQƒŸ€ÙáÐw¾CuÛè9µÚ–ñÞ+b‘ô/ÛWŒv¨»ó­³“!à$¹Žfw‚UBÿR}?ª"‹å.ww˜>ÉBJâÕ8ÌtîÁu½
š4¿SY—YÞ¬W|êõæ²'Ôò˜4˜¡ƒüØIš´à§¿ðÇT9Þpé-+wi_â'ª¸Äž4	£R3D "A2z´ô3é-~¯Nò0/ÏµoYŠ	pW3Ýok\Õ‹c7º8è7Oœ7HÍÍ1"{VI¢è=›q®€1føÆÙßèþÎþ~àB9è†Ûv¬l?÷©#^ê&?S›ÆåÎcKB™Ùà„'"è@`š†K+w5ÈÑËË1ÌŒ´4Ë~¾`éLÕ)V½v§:<&Ûß9‰'$«ïZHVÏŠ4¶ñB?eR(÷ÚZ8ú‹P£›ÐLçg°‹6€šœO;Þ$¶xšüåUŸW×Só‚!ËÔRÐ-Ðe+ÇHíÈU‰àmF€î'™8õÞ<ä´•}/ð =Fu;Þ§ày6B°,–¾ºû_‡KS=J ˜;ÈÌÈÍQ ÊzÝÍ–~ªqºCôH\/‡–2Â›…–jŽÀùFÝãê":*’0­[¢®#*ü‹§¹ÌÜ
F‘ëÈvØL6
ö3 t(,œ¬ú¿š2ã•Š†¿îW‡ÿÿ“fiñ“FaZœœÉjì‡ªÌ5ý`öíyl!°æVŽgÊaKó”¹õ+ÚÍÒŒ¨$?üÐq~–µ'‰áV“ ÅÄ©`®#§FÒÒßÂÖØ{
mGn
ü¬ÍM˜¶ÙØ(ºÉdêŒ>|É“ë`Ó™	£ð’	ü²ÃµNŒV Ö
WnÎ©3Ð¸moÁ%!:våYe»ašßJÅËýx‚^ë­‚Ê‡M©»|)©½R;¼?öë_“œuOs·TL+ˆK%M=‘yU ìåˆVÍ×…ª¨º…mê¦ãÇ•£ë`îÊ¸¹ôºUJÍñ†/€ÏÌ~T“°;qÓÇCGÎa^¦ñ(Ù[A½¯kh¿ÅA;·_Å?ä‚»g±"-‚›0uØ`nÊÇ‹r9rOnÔóG
úŽì€Œ\ <“òW0ÐB‘˜ÏˆQi"1Ìƒuv´ÏBc€Ï8ýöJr !ñšWã)lRøŒïz2Â¶£™†SUýëµ¦ði6h@‰ëHt*ýKeÄßÀ>ÛB
Uî¶î}†ª§G‹µ€*AŸ–øG{è9Cÿ¦ðò£JÝˆûB¢ÕGâQ
5“ïÇýfæÂ?È¡ÿ•(ôÝõ;ã:¨l–oTSSÊ)°EgŒ$4Ù· Õ!æà³$‰Ž%Ri‹ÒXXz£açÕ›ÐÓ‹òùÎI©BÂÀ“Ãª6þñµ&±ÀŒŸR–P\k• _%eÆÀ˜e©j#,;¹ŸäÌ?7éÊÄ¾(tÑÈK?¦¤×h2!<•ßó7àÄIžâ¢§[úÐM*ßÆWxYc1GC€âˆøÎ˜ï±»Újì­þ¥î0FèQ!ä¦þ¢Uñy*”wÍ.ï”:¶·W¥ÉTé’Ç”›‹RÌ_¤zád¤¡Þê=‹Ž‹.$Ô¶€ž¼«eæÆÖ±v/œ›§ü ÌbBsÍÊUê-¨Dû"‡hÓËD^?!š(¶*‡¦rAÍ´ýo÷Ì);áyà	cÂ&b6`	ÍÖ‚øwqK×´w£¶/^l2•]€Öwæ¬½vèà`¯C˜çJ£‹¨SÍºÎ÷Ÿä(ÁìëI°«Ï§‰þM˜y`Â!mºì¡Ë¸\‰RäƒëÜ
w÷ƒõ=-ìã0Ëzƒ%¦ëwÉÌ‡Ÿoàö&/†Ñ^Š å‚W†¦C’e1Ä€ÿß!æ’ä°´1ñê¦IH-E~[b¶AŽ)É…¹ô6/*N†ÿh€¸Ãý}Åˆ3Ì¾¯ÓûgÍ4“2Þƒdf.Ã‰º‹õÔÕƒÔ„×Ó#Íâk1êÅBü¼êµ¿ºw(nÞkmàx,QZ<^šÄ Î©Šœc>R{C`p“¦ ›%öGn…³’ÖQY¬ÄP§×½¢…×÷8aü87w±ÍÅZCXö´ïë¿&µ5Bÿ ÄnF;•§dæFõŸˆ/ŠÕ7B¸h²®8Þ¿7‘tÙ {;Em¨=~S9rïƒýGªKŒgQ ?ŠQëï )ð\#"KÿÜX/Ë¸´¬l;H6aî*iÿ·ÔÏ¾©ô3r\CöayýV—óCžÕ&êX”@®Í.Hû´ìÚIÎ/åugØëŠr¿gB^c•è„+Žä™ªad€Í1ëZ«ZsûiNù²ºÙ0zá&çuÙ_€¦Í$D{å«Dè;î¯'®n>cêW	*þý·›,ð^
‰Áv›0¡€ gÈ6 DeÇ%œngÜ•Å¯Î1$Ðî!$g›};åÓ>¿3C+lW½>…	eÀ&Öª¨lý²Qœœ“iÖ<´óØ¯-ŽÓVø¢bÇKn+r‹5f¢±¢1`–ÿP(Ž'	È}ÜŽ’*9Óžy¦	‘~0ÛRáÐèÐ²Þ˜ô¯“‚¤Gýú6ÿ€|}Fý|s¤^àœý/:>§~î‹×`u%“,žknŠæ*ÄÍ†VÃ~‰õ4î¶%X¦ÃØâô³´³Ì÷÷[ã÷0u¾½áôíØ<r:y°âÊ3èéàcfo–üßDô{½o´ :"©—ª¼±x§0	áq
¯@M÷êsˆ}a”¿Úü“<ÍÐÚÉÚd<»Y¼óè@O!X»3<ûþÛè"üÊ2v­¿ÀÛ-ÿ8G´WéSÆFÌÎPÒn[fˆsD–Ö3Iš3uý­K¾r!è‚;tb{øuÂ[[e7¯väÝWì­7tNOÎ{zõ€»ŽmÒ%BC }å¯pC%|‹ÁôÇÀØÌçWÒ›5ü#ZœÝ¬>t‚ú]ÌÇi{QÊ|åÍ'a_ÏZ}òi
lç1¬1|~mý—.æZMÄ]‹úé®!
œJvÔs<0´B£¿»sRÑ*‡ù¼|·T¤¬ÿƒ	÷[&âqÁî˜%à±æŸ„@¶UÉêã'ÍßOe<®_¢Ì…_Q|n˜.œ’/ØCrT_Å“Žy¸ì,‡nyþJÂcN‚µ‡G÷Z(ýYò; æÃDPœÌ_>„£ÞSüÒÚËîÒä3ÐªŽ"Þõk@&ïTT\‚z7¾wzf× VŸ¾à‚˜†$Ê'åÌrB™Kí¼‘
WH—xñ4‘ ÍHOÏàœÎúÀâéÛí-‘á4hA@è«ÝËwlñ}YV’aÛÁÀRÐBã'LP%Z%BÚ
}j´ï<	pSìpeVd‹#žÀø+ÚõÎÆC½!çž#%ä}°«•`~6çò–6ßžõ¿_c¡þM˜ˆ$ýwÝãÎïjýùoôŽù‰ºŠ•ÉæÒz;ÂªDeïê®#45UuÑ3[§2A7l²,89€ÐszâõC>Ãl´(³[¬Ò¬‡ÈOHÿ¸P.6pEW”þj@Z_0Êÿ…×%ÙMg™…4C K¤=Á{ý©@ôJãœÁOIÇ†Rûk(Ãri ýÈo.³.«ìR<@5?ò÷ù­ˆ£\GÖÙ$m×KfŠ²fXÕ;ÕØäÄ Éa¦úvQÔ¨6l;Ÿe,w|,È1ÕIs	r\þ’ ™ËOÎù$Ñá ú-xØGÅ¿÷%»Ò}š…,&yG3¥Ã;ðM ~•:àPI3E*+U-8zéKäk»˜OXPüqr.æÉTs]‚"9È°"1å«-„§µæÔ>!º=jÅ²G‹”µ7HßÇrÀe]âN›‡ßj³Ý(¿n¾÷Ž 4ñ§ÔÎ¢qàêÞA®{k3/má†$áBÁp«æ3ÆCƒÞIiÇt,ýgÓï#¼—¹Ê¡5¹LûMÂÊè°°YÑ£¿'Wk˜š{áÈtÏïÛÃ<)¤éZ¶ÔxéuÞ?–¥M›å¡røx²R~’ÊkUãøÅ`ï+~}LÂåWù²¨({7Ã’qš
C|-3Šqþä×ÒÛ*bäÕ_‰“o¦À&>ë‚P;`=‹ý±žØ°¨¬z¡ÛM_Q›¦þÿˆï¬D¦Ú‚Õ·eÃ
"Â?1˜ ¨Ni/¼A¢eN/±Ìç°ÐŸ
Ù5<€¡†«71tÀËj‘2ü€®eø•®ç¨Ç0^
5»JžHvqÇµææ5ì²hP½›oqX™È›CaãZT‡B²…Ï+š6Î| ¯Åp¢º.dvXVmÖýß#÷.æ_.z”âÃ¬ÃMíMuŒŠË	˜ƒ¡ì	XªÅÒ¥«& LXÈOTªzž&oˆ^Ý³¬»&/h¤Ðú‚à¼ŠI¥ÈC¯¯|¼D‡NN^âMáâu€/d.å‰–fó—UµoQóœ–$¯©H6ŸÚ=(y´%Ò\¦XµƒŸ#Ï„û¨ów´‚‰cÓÛçm…g ð§ïŠ•mEˆ– CŒ±G-ÚeYÂS[ÒÓÀ”lU—®¸%H¿JLUTƒÞé>uW5%ÒQq¸ŒCÁdJgío®ÃEW©Yã‘”’”šAÐ¼'wö2UÉŽ+ÆÔ€Ä$ËvnL…¼ïiìDB°j§¼z£xoT5“y²‚Ìý9ŠÇ”ˆAµñµµœòxÂ·Ó\@nóÒ'V\W½¯ˆÕq´#eâÜòl·!“õë„>sõL#>òôÿŒ­ž¬—/®pYUÎoºb©qÀYÓ¢jm‹ìC~¹wôáb+8ä#é0{ÔÿN`fö¦1+ÛÉ¦ª&Ç„”†j+ß*¨i(Ï‹›Ö$µÁHža\ËžyW£ÏC‹IšN®¯džœMÖ„lFáÑfº™N<Gr‡Q.YWBïF! 8a—Ù ™`ž,SÇO)0I›rl3Ú×lxÞ¬?	Ò«à¢¹âK¥Å:˜½î°´Úá%“x¹“w©¢n'ÏŸqÊ:GÃõ”^ó÷¯„r-Z»›­œ÷hy®§imã¥{~å;óü¿H‚™ºz´ïÊyÒ–æ©¾šÌ‹Ýð!¹Û<õ±¢."líds.ØmFI­3YæîuRîpð@I&»7ÃÍ!©öÜèÔžÃP#_ƒÆÛ~‡2Z?ðZ8d³£*¸!>ÞÓü9EŽ=>BUŠÕ„&?Ã;ÀÐk{´ŽÈ¢´édÂ¦Éí’þ)Ð–_V˜6ˆŒ¨Èá©bÈÂWê©ƒVZóXeÓÜòOkJÃSDsÏ+@þ9ª“æ§Æ–éîÈÛ(¼/4IàBpÂ×á??~!vPÉäFÿ¥¢ïð2ø‰u¬	ö'ÀìõnQ·Ðl¦ÝÜG|Í!@í±G¾Æ”CÁ‚ƒÊÎ/@é9+ïäÇÈŸPèëD¿°Jz€Y¾¶^ºŽ?*ßïÉŠ¯ïeCAÌDBrkËÈSä8 A°¹„Ýi±þÂÉ”RÅp{÷¬=»—–n¯­Èþµ¦CqœÆµÄáÏjfµ¼YÛÜA	“Ê0q¶Ëöd{x~-¸pÂ“Iˆ-#x&ÖÌ‹vãÒž¾—@‚2Ó®Y,±iâ•di¬;ôª<ÔëSøpÒŠ/ïá1xH±ÖÑ£ãcMìšóCÄÀvr8Ÿ^ÜƒÛËƒÖÔ}vÇW˜hÐ@ô_u(¯Ñ’Ù!âï.ç,k«ù»DIýEk3}¢	t!×n@Dœ²SzÖÁ²„½’#s¶D‹Ñ) O¸;XÄ¾R²q•ü`<É²Ãý‡ÕÝ<Šá—›ç&u’©¾•™uBœnmmÊB3½rItE§fPˆ$õØöæº3.NJVÔrv;ËeŸS½¹áxàè¯/Ó*Xá‹ôÃ=°.y%í‹’àû•j×€-Êÿåß ¦õ5¹ùìB¯k•¹ªŽ¾Œ¸°å6îå¤ š„“|©ÊÊ%-§ä¥è/(×F¦YÞ‡gŽÜ™ÑJé[4ô6Ã¶;TJÌVpžÏ
LHÍÆx1¿mV³÷@bûŽ_SÈì’”ámóD*,ˆè%ÔÚo)$R”*?†™1? ;ÉŒ£K‰_†â®HÕ½ÅåÚÔÒŠyi·Ã
†»C#f.n½ …¼NS¶† `F,6¤ú+ÉRÕ+b{×åR	Ò‘_Fk’³Å+b‘Ì–¥S¸T°°À“Õ}HwFcTZ¢^w‘	Ä¿»ŽUe9 KÚEK‹’/<°‚ ÀEX½³ÅÕ@é<f?­Ç-™»Óu¿ô’O¶	®âï6NØÕ“rr<'V¹,~Ë+\g«9Û#¹²&[Ùè²ÇlÓz9/äcôõè&ðîer4i}x„„€Lóf°*¬3œîÅ€¿UAÃéÌ+¶$ë:¸Ü‹þÖvÙ{‚7ýO*D;4S¡ÂÕ!@ª¿Ï»0Jæ1Pµ—  £°Oq7D¤K“Úù©§ÛN×/ÍS«–¡ó°LÌFÕLœ,×4áÖ…¯SÝZ±Ø#ÇÉ …`iñ^>W²‘vý½
ÍU‡.Á¡¨
è…ZZZ*ÕµfË|€ðö=½wäØU,ËË±ß•Œ¶–Ñ´‘àcyëfBî',øC4Gðà1¬Øü´Nù¸ŒïüW¨`2‚@zŽú”8YÀ†i{	´fº›GÖHcy|…eRÌ‚‹1=rCò8¦t\«	éí¯ÔÈ(&l<Æû-ó¬iðä	É¦§IÄ“Í;²ÜQªÎ#x`D_ÀkøVzš\ð?[Öƒ@(èÙrû\ã#Fxiò<è& ¯WGþ°‡2Å”x	ÝÇ[S47“ã?ž --gÎ%dï;Ù¥k+‹óÒ¡ÂéaÃ”€Z:¾Î¤%õŠ«~ÒÀ7ÿÜ°­À€e6™,tí÷ü¿ØZ¼b­"<XˆÑÉÎ5Åð$’BM½Qü²ïû2æÌ¦47,M³Äè­S‹£ÊØÞ§’"üÉ8«ÛŸõJdÜýTêçø‘'Å›£Ø”HKƒûXóW~eÊ3ÝU3¸‰€¢N8™y¥#¹iADþÞ)>¹>ŠT$¬É”áz«'ØVýú^
”ß8”Fè¶Ù\dÜ¬(I	M‡<à†ÃèËå¸t‹x-3_˜»½æ<6¦Üx
á²p8-Gy¦/y£u5W‡‘
³ë<-äSLÃø§'UáÜ@Š<›;ðšnçÒÎõ˜ÊedV­<‰ã1¶f-e‹Ð„Aª®*p,@i²ÏÛž’Í¯ÀPìã²îO&Ë?ŸŽzœyB~xú¹q&¹Uù&=ðX$”póXMFõs}úî8ø‚AÆ'ØI€JScEñÕ r¿}Jë|TàVò[›©;	iæMq¿’aD¥pVxSg’®’Ðs°ódÎ®0+ãî!@§	XƒÐÇÄ«%V& F8^¸Àt¹x*y –ÛŒý7abQüÑu‘K†cœ³¬†÷ë¦OEÈ+C0{æWÑs“v¡¿Äèú“Â@£¢Ø"–LpÄ{Aa’_R®`ü9]IJÙìÓHãm²ÇŠV,8¤]óîèäŒÎÑ°Ç¾‹Ý1yÛŸî6t¬;ë-Èå'£Q¹f!­HK= ×ˆX ÛLg˜ìmÒÝ‰…J$1sZ°=Ô*¯+‚öC4·ÆÄ|ãK
25\õ/˜DÌ´b:páqÎJÆÖ6Ws´£´ ýüU´±ÓŠœÁVCÞ’×ç®°¿JUóDJiÏ8Ô´9æ‡—Äƒ8Üƒ÷@Ùv¿§^u…°˜¹uZû¡çˆ©¡Þ¨õ„ÑžÎ¨.î*ë}wm1óÄÉäÚ  EtÑ“ß‡€	±ŒÎó'=^· &”š.@äÞZI
ÌzÝÝúœ¶Òàk2JŸbR#V>~ˆä8LÎƒRìpQS!m†¼ÎÛ¿
£N´ýtYóß÷yë¨ßg| ZN/p
é®‘ÿ¥iôŒ_ßÔ£¶ŠCPRöU²ù•)öšF¶†l‘c‘žÍ¬Ù]Oû‰Ü„J2Ñ”½ÁíZ
CA¬Há"x¹š°#|0èÎ#ÜÓKfqAÀÚ—â»™iKþ8×ªö†ôJYZnñ¶G¤¡{_­™£†YzÃÛkYÊ5‡×fÊéøiC¨5Î9KìNÊí.Xþ ÅwÞißyœ›)œ!µø­÷²l‰ék$ÁŸ~Þmb=R¨bü6ÈÐ7•=Nö;NC—Æ‘Â°üÐÔ¾Õt<´âžñ5GT1~µ²?¨{Së|ÕÉy¦ž7{t/õ!*Zv\Ù“_ŽEž“íæØ-ÿUÉÏ¨g$z{ToŽvšéìöÂUQÄôä±ËŠ;Êß>“®çúµu1`äÀÖªÂvlAË¾À¢¸ÏnB8"IÌÑ1Ç‡=<¸!yt #6xâM¢ð7r^y}—œÇcmø*ô6g­Óˆ&H)I~@Ù÷"'vÅ®7w'µÄ|r1t%ªÓ~ùÆ·BE÷=B³àZaÒ‰ÍàMIS¾ð¤iôwè‚q¯9´õ1Ï2Kå+mGD?Ñ [sžcB„XºlÛ,àE°C‘Ã)½0qpB‘anÿ‰hBÁýzœ)–±	¨÷ºë‰}F­†GÈZ°*É´)Rk`ßiÚ|’q.œ%V®Óô¡< j—P”`½³")’î~$`¬ÁzÒ€ê›vl<²¦J\:ªbø^…!q‡´`ÙÀ²š:…±»œV|	“/9yrt$Ôm‚YŽôáCUçš¶Pg&b¢õÒ#/L–£pjóÄŸç¥â=ÿR'µ£F¯l!/âS5.éÙŸTê’Šz¿m·Ll
s!­º>]'`n6uã«GÍ„æ!oy:ùóùg«FÓµ¹õct4À›”/Ò%¤ë	O3ÖÔøD“3>‡-¥2sxç-nK¢¢=7:\Þüf./<I5GÝh…d–*–	£~7ÉÙ³Ôë'Gî$­Sê gzˆíßu(»ó_Í½9’Pl¡x³œa¬ðKÍŽk5	ó"è:]:õQšÂÓC¡$¯BœcÒ9Å)L·|‚Àp¤©‚Þ¼ÔYV—h*Ú	NŠLëî$³žMÄë@mÆ°o2ðvïÅÏF\8p7A¿ÁŽª°­ÏcL'8"h¥é¸XK¨Ï;nŸÊ×ò²Ã§\sT+Ö HþØkf~T6­Êß}N‡ôz,Ý´‰P	µ'ªþ&ƒjŒ¿8mÖêÜfdûß™	v½•ÇÇKîqJô´¡öt­/áƒHË`®ÓÄ-Ï£ÆØ¯=–E]óÏÛÄ©ºVêåÚ2±:á„ÿT¢Ö,RÃ—!(
ðµ”»p˜Z}ìŒ/'n³&}ÉS5fø³~Ü‰á›ÀuW0j‹‹Vº~†m¤vmV«‰½¤=<¾ÅÉûa‰p¹º}#Ez]Âøã0æ§
=R”ûöÑ7´ëý}æ_WÁÔ<Ý·c ¯FÑM-xWkÊëfÁ½žu©›óûûç¼»PÃ™&9·mšƒ\NHl…®§y>¢t%µ1áô{µÄˆÀÉ"D%(’m•¡s '"G aé‡ŸEh¥:ä³T™xÜZAÿžg(1Õ½ÓH^úk¥šÌ¯S.õ¼Ô0 ‡„: a•Aa3©Šd~G7Ç¦22KÍþÚ}Q	rÝ£¯e(ée‰~§ë²PuÎ½O–cÈ¯NÇŠÌ“?'qâÖ×
À<”>äñ4õ³X™ÙbÆ()PôBä3iU?,ÿi³>M30‚)8…Üójº“ª‡ìï»UEÐ•rð•Û¤Ô)×« =0ÝÎOÑ8Ñ‹Ë{–Sg†½ËßS=Ïèt½BLÂíMÿ*Ímû>‡Òº%!¤3ßp2®ãÇWØ	£šöðšh‚nÀž@z½fœb™{Ò­®€ÉGç¢Q‹=G|×\—?Þ¯®ŸNîT¶mî2@œàÁ,ª	MZŸŠ¢bÿ´¢ÝcP|±?–½”M*ƒk`-K
6_W‘ÿâ4D3Ðæ37åv$¢qÍŽñ8­Qeø\œX´.X–btÛ•EÁ¦yù3^pW {ÈÍ	¹¶l¯g7`²™Õ.OÕ“Hò¸_ò3(À=âÆóí3£U;«qs#á°;üÿG‚ xt3¡5q„ûdr.Çj³8Ý¾[êŸ%›6+RO®SÇ#‡iXøíT]_‚e'í_Ë×»¶wÇÛÒ?%aíx)ÿ’hø€¼Uà?º-Ògù©"¯ ê‹4½sãþ`\(p\ºÙT;•©Õc"6‰ûà¬«–65TÔ¨7Ó	“ûyï¶SDñéí¾Q/Á‡¹½hehiüŸŸPsH‡FQBËøOê=÷ÆŽ&‡ßD~E­èALˆ’¿Ð!5HìA@‘*Î"Ù]H`s(¥ònRÛ¯žcB^3\dU’¬BÓíMd`3:9ƒš¬?ö’ÑÊ05Žhió½û ÿÎŽM3¦®fáèöe‚úÂñ,TÂ÷…ø`mh¨76ljÝÑ¾Ç#…Â5G³aœvX!n\5ÏÉ=î2åiyÓù“¤·–lÛ/cãqÿYÊ!È&W—ð”…"z’Œ–`ŸG5q"Q¡2´„¤´ÞnÕ¦•->…ÂÄ¨<W5Óc•cšª8Ì‰­þ>1¢òÈµ¦öó,¸¸Õõ
ÈrŸ+t9Õ­E¢7ò¡u#Ch3U0èû'Ü'ß•ýÔ¤§È‹àž8&@oáå<%Mpz~Yv¥6ž„Ë›Yo¢ö†I¿*]JQžºj€ §¦í!kp—¦5–rÐïásåh½¥yèÄ9¡£"JÈbêxÓŠz· ì‡Îûõ6¸š°¡tÚ?ô~aÈ* +™þ–#xMCdÕS2ÐIi‰ã*Àƒ"•LLµwaOv÷rîE¶S
†ëSïu6 ¸–¥x)š­uçcíH²c@%R…Ü¥ æ+‹9 p#¡(¹F¡Ñp<å#ãÒl•6­»ˆ2—-Ò}Y^·t_'˜ PQGñ#·.£œQ†o¾¥k×.žo[qíµÏ¤*.ÌÂ/v7-<ÛÊŽa:M}ß¹UWÄiÈ±˜UIÇ"ö>mMWšŠ2e”Ÿffv+ö?ÜØ2_ŸTj–“Šáâžk„¨¢êº!	!®L¥¿)»—\7±…ÍEÐ&òo‘r¯ j7	‹æ‰Ø‹HGß^açäU÷µ{é$ð–# «#
â,•ÈµmTþo›ÝÎýôÝåÙ3ÜŽ®Æ²»¶HßVôa×/÷ äeõãÔÁ¢Žµ€s³PbÏÍý$ …ä/|…áz÷¶¸YšnÚýŽ^ðuêCgíô<jzQLôH \šo7¨mÅˆµ}rÄÀuÑ'…ÞzôlËé´Îé¶+„%b-“(5Þ²Ž¢rtšŠS¯n.ùÚúâŽÉÌDõQjW~þ³]e© Ø­ur7È!<6P5JŸåä	6OaµMàhh>Î?§¾´ö}:2³‹hÄÕdêfIóœ˜TQæ5ºOs‰`³0gIä„H˜±]å2ÁÏ˜Â5£‡ŠLAÙ¿Ë:rûYÚEo¿É¸XÙiµ¾œw5‚Pk&gò°³4ŠsÿÄæûÀ@Œ	E×ã®¡K/€†ë­æÝ]šè¬óÊ´LW4Vœ9K™Û–
$ŠÑqà/òÄŽÀ]åô´‚ îÍšÉc8Ôz\^|.Ï\^ÚNvóR:ÿcÈÀÀ®µt0µbýO,a‡ Ûä^W.´rèüU#ü¸ì¼yšqîË'QÉw}*ÿ~äÝ]øjSjv"bÉœý:ŠÉbÛ’ÙX¼Ù×Â½´¶¿1 ÓFsã°êðÓM¹oJôùVÕ¥0-b	%Ç¹E}xvL½0mü @IÙ°“Í©òºd ­aÎÀÜÅ^ñ¹1×@MTj¢ãˆ§èë1ÓšxªFm¢‡ÓY}GNò Ë@šÃ¥ÕU‘Œäçðº”YÖìRüTðJÌö.LÛ½7Ø—3‚À·^þ4¦#ŸÁÅ‚R² X\¦‘Y>ëj\>^2_þµ0üé‚R†Ë^Ê´(îUÕ­–Ï€@qäµˆHÛ|îšEq¡—‡'cåñàlärz]óüdáSí*àÉ§ÏcìA„È,ç®þ¼ÿk ÞêÑ‡6ùÚ#$»ìË‹P·ÌU;•‚"C¡!  ¡-k½<ÕŸrÏz–ó6ƒ¾ÁÓuŽ)±$«ÓhLôií
íÈ3*ÒmM3`„¶FŠ•Õ³Fù_a«Ê™Õ³~æ¨;¹E¨y	‹/)Ñº¾¦m Ìx-Í¾¢Å<@¬å{f*$m£.ùÓWËrûÈ9@gâR&…bÅÄGA*rf˜”‘éë]wÏrâ:V÷{×‰˜åêë¾‹CÏçêa@)LF”_£Ò½Õ1»Šb¸t9×ýÑ½	»¨ÇFë–.ÖøoÿDµ“£X—j8ƒ‰u Leˆ&«ÀpkôPðõû¸3­*j3Àúþ‘6ÔQ"œ"•„ì\ŸÚÛø¡[]Q–”íâIUC?œ?14. ¸©Ž<  ²ßÆZ‘…í¹Å;y¤_¶×èŠÒc‰¥gršÃ@|læT¸WV³ GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0  .shstrtab .interp .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .plt.got .text .fini .rodata .eh_frame_hdr .eh_frame .init_array .fini_array .dynamic .data .bss .comment                                                                                 8      8                                                 T      T                                     !             t      t      $                              4   öÿÿo       ˜      ˜      4                             >             Ð      Ð                                 F             Ð      Ð      d                             N   ÿÿÿo       4      4      @                            [   þÿÿo       x      x      P                            j             È      È      ð                            t      B       ¸      ¸                                ~             È
      È
                                    y             à
      à
      p                            „             P      P                                                `      `                                   “             ð      ð      	                              ™                           X                              ¡             X      X      „                              ¯             à      à      (                             ¹                                                      Å                                                      Ñ                           ð                           ˆ                         ð                             Ú                             ÎE                              à             àe      Îe      H                              å      0               Îe      )                                                   ÷e      î                              