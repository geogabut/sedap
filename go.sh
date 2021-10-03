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

mainaXq8��$
ty�N9#y\?85�W/�.m4���r����U�2t��b���ۗ��q�gFDT=s�͸����dB��:�1��]���
/hH`C!����������`�B�Y��N�v�ތ%���(�� ��MV� E�h���׼��N۸���>)��4�������g5g�Jܶ[�����s^�)0u���wz)&��[ �ˣ���-�S]�B(�#xa�}���h�K�N��V�!�C2����>ǼSLE���߼bXa���0yd�g�w*�flx���{(fZU�����v��U���䪘=�ϫc��x�.�y`���y�UU�	�k��u�r1���j��NE[!M�ޝ/�L2��Û�����p*��N%�?\T)�Bk��>X��e=;����k:}�����b--M���j��3��0��x�JF2��*G5����&Lٌ�#������[ht������^��
�1�88�w�+s�Z"(�ppDm,�%뼪W�tǉ"z�P-0+ٻ�rݚ�Eՙý�S��o��,y_*o��S���gA�]�{����Ab�!4t޸���V�{��{��z�g�`�*s�_>w�P�NS�����������9�|C���@�0�,9��b'U^>�|?Ã%ua�\�ķ��J��4��z�497@��.�����������dkeaƥX���^Ff�0��y��xX��� �&j5�~^��\�w�i�9��� �z�e��9<���(-N�Z^k��\<�J���Snb���Ҍ���Ihx�-��}��-�X�-��!�7��oU(��sY��ܪ�9��]���A����p��(��ws����RC��f0�u�1ﵷ@��l�iBs\WTMj�۲sL��ɨ�_VV�z���a4s9�0*�!��*��V�:a���	�,�GM�v�~���"Z,9����5N����� /���:e|�A���&�φ';��Y[��7����d�)��/W ��EU#������и�H�4���e��̽ō �&�:aJ�fY+�&��\񌁦�n���T��c�ѡ���	����Nj�Ȉ��/|8�d=����z`M���˞���T@Y�'�;�"j�zW�7c��$.հ0�lϸ��o�Ce1�����Hݴgo���Qm���҄$<�U��咧�������!��؛��]�2��9�����Ƨ��-��,6�V�Lo"A�]���ԟ�+��z�r��z���b��Y-h�/�W�"��7"��N���+&��%V�dt�ǻ�՜�����j1 ���UF���q����i�2W�P�/i�mmAU����C.*�\�ϣ��o�DWN8|`Sf�������M�Z���t`��$����#R�؉��M��a�y2z�J0�p��+p�P�#�p��sʓ�~���pG%ۦ$�0�q�vR6�I�4;��2�x�!������@�P���WgG�/��;Ƙ	�	��Q	Kա�W��65־uJ�~"�
�4�SY�YެW|����'��4������I��৿��T9�p�-+wi_�'��Ğ4	�R3D "A2z��3�-~�N�0/ϵoY�	pW3�ok\Ջc7�8�7O�7H��1"{VI���=�q��
F���v�L6
�3 t(,�����2�����W����fi��FaZ���j쇪�5�`��y�l!��V�g�aK󍔹�+��Ҍ�$?��q~��'��V�����`�#�F�����؍{
mGn
���M����(��d�>|ɓ�`ә	��	��õN�V �
WnΩ3иmo�%!:v�Ye��a��J���x�^돭��ʇM��|)��R;�?��_��uOs�TL+�K%M=�yU ��V�ׅ����m��Ǖ��`�ʸ���UJ��/����~T�
��쀌\ <
U��}��
5����f��?ȡ��(���;�:�l�oTSS�)�Eg�$4ٷ��!��$��%
w���=-��0�z�%��w�����o��&/��^� �W��C�e1Ā��!�䰴1��IH-E~[b�A�)Ʌ��6/*N��h����}ň3�����g�4�2ރdf.É����ՃԄ��#��k1��B������w(n�km�x�,QZ<^�� �Ω��c>R{C`p����%�Gn���֏QY��P�׽����8a�87w���ZCX����&�5B� �n��F;��d�F���/��7B�h��8޿7�t٠{;Em�=~S9r��G�K�gQ ?�Q��)�\#"K��X/˸��l;H6a�*i���Ͼ��
��v�0�� g�6 De�%�ng܏�ů�1$��!$g�};��>�3C+lW�>�	e�&֪�l��
�@M���s�}a�����<�����d<�Y���@O!X�3<����"��2v����-�8G�W�S�F��P�n[f�sD��3I�3u��K��r!�;tb{�u�[[e7�v��W�7tNO�{z����m�%BC }�pC%|��������Wқ5�#Z�ݬ>t��]��i{Q�|��'a_�Z}��i
l��1�1|~m��.�ZM�]���!
�Jv�s<0�B���sR�*���|�T����	�[&�q��%�柄@�U���'��Oe<�_�̅_Q|n�.��/�CrT_���y��,�ny�J�cN���G��Z(�Y�; ��DP��_>���S�������3Ъ�"��k@&�TT\�z7��w�zf� V������$�'��rB�K���
WH�x�4� �HOρ���������-��4hA@���wl�}YV�a���R�B�'LP%Z%B�
}j��<	pS�peVd
C|-3�q�����*b��_��o��&>�P;`=����ذ��z��M_Q������D�ڂշe�
"�?1���Ni/�A�eN/���П
�5�<����71t��j�2���e�����0^
5�J��Hvqǵ��5�hP��oq�X�țCa�ZT�B���+�6�| ��p��.dvX�Vm���#�.�_.z��ì�M�Mu���	����	X�����&�LX�OT�z�&o�^ݳ��&/h����།�I��C��|�D�NN^�M���u�/d.剖f�U�oQ�$��H6��=(y�%�\�X���#τ���w���c���m�g��mE�� C��G-�eYS�[����lU���%H�JLUT����>uW5%�Qq��C�dJg�o��EW�Y㑔���Aм'w�2UɎ+�Ԁ�$�vnL���i�DB�j��z�xoT5�y����9�ǔ�A�񵵜�x���\@n��'V\W����q�#e���l�!���>s�L#>���������/�pYU�o�b�q�YӢjm��C~�w��b+8�#�0{��N`f��1+�ɦ�&����j+�*�i(ϋ��$��H�a\˞yW��C�I�N��d��MքlF�эf��
LH��x1�mV��@b��_S�쒔�m�D*,��%��o)$R�*?��1?�;Ɍ�K�_��Hս����Ҋyi��
��C#f.n����NS�� `F,6��+�R�+b{��R	ґ_Fk���+b�̖
�U��.���
�ZZZ*յf�|���=�w��U,�˱ߕ���Ѵ��cy�fB�',�C4G��1����N�����W�`2�@z���8Y��i{	�f��G�Hcy|�eR̂�1=rC�8�t\�	�����(&l<��-�i��	ɦ�Iē�;��Q
��8�F��\dܬ(I	M�<�����司t���x-3_����<6��x
��p8-Gy�/y�u5W��
��<-�SL����'U��@�<�;��n������edV�<��1�f-�e��
25\�/�D̴b:p�q�J��6Ws�������U��Ӎ���VCޒ�箍��JU�DJi�8�Դ9���ă8܃�@�v��^u����uZ��爩�ި��ўΨ.�
�z��
�N��tY���y��g| ZN/p
鮑��i�_�ԣ��CPR
�CA�H�"x���#|0��#��KfqA�ڗ⻙iK�8ת���JYZn�G��{_�����Yz��kY�5��f���iC�5��9K�N��.X�� �w�i�y��)�!�����l��k
s!��>]'`n6�u�G̈́�!oy:���g�Fӵ��ct4���/�%��	O3���D�3>�-�2sx�-nK��=7:\��f./<I5G�h�d�*�	�~7�ٳ��'G�$�S� �gz���u(��_ͽ9��Pl�x���a��K͎k5	�"�:]:�Q���C�$�B�c�9�)L�|��p������YV�h*�	N�L��$��M��@mưo2�v���F\8p7A�������cL'8"h���XK��;n������ç\sT+֠H��kf~T6���}N��z
����p�Z}�/'n�&}�S5f��~܉��uW0
=R����7���}�_W��<ݷc��F�M-xWk��f���u��������PÙ&9�m��\NHl���y>�t%�1��{
�<�>��4��X��b�()P�B�3iU?,�i�>M30�)8�ܐ�j�������UEЕr�ۤ�)�� =0��O�8ы�{�Sg����S=��t�BL��M�*�m�>�Һ%!�3�p2���W�	����h�n��@z�f�b�{ҭ����G�Q�=G|�\�?ޯ��N�T�m�2@���,�	MZ���b����cP|�?���M*�k`-K
6_W���4D3��37��v$�q͎�8�Qe�\�X�.X�btەE��y�3^pW {��	��l�g7`��Ս.OՓH�_�3(�=����3�U;�qs#�;���G� xt3�5q��dr.�j�8ݾ[�%�6+RO�S�#�iX��T]_�e'�_�׻�w���?%a�x)��h���U�?�-�g��"� �4��s��`\(p\��T;���c"6��ଫ�65TԨ7�	��y�SD���
�r�+t9խE�7�u#Ch3U0��'�'ߕ�Ԥ��ȋ��8&@o��<%Mpz~Yv�6��˛Yo���I�*]JQ��j�����!kp��5�r���s�h��y��9��"J�b�xӁ�z� ����6�����t�?�~a�* +���#xMCd�S2�Ii��*�����"�LL�waOv�r�E�S
��S�u6����x)��u�c�H�c@%R�ܥ��+�9 p#�(�F��p<�#��l�6���2�-�}Y^�t_'� PQG�#�.��Q�o��k�.�o[q��Ϥ*.��/v7-<�ʎa:M}߹U
�,�ȵmT�o��������3܎�Ʋ��H�V�a�/���e��Ԑ�����s��Pb���$
$��q�/����]���� �͚�c8�z\^|.�\^�Nv�R:�c�����t0�b�O,a� ��^W.�r��U#���y�q��'Q�w}*�~��]�jSjv"bɜ�:��bے�X���½���1 �Fs����M�oJ��Vե0-b	%ǹE}xv�L�0m� @Iٰ�ͩ�d �a���ō^�1�@MT
��3*�ҝmM3`��F��ճF�_a�ʙ�ճ~��;�E�y	�/)Ѻ��m��x-����<@��{f*$m�.��Wˍr��9@g�R&�b��GA*rf�����]w�r�:V�{�����뾋C���a@)LF�_�ҽ�1��b�t9��ѽ	���F�.��o�D���X�j�8��u�Le�&��pk�P����3�*j3����6�Q"�"���\�����[]Q����IUC?�?14. ���< ����Z�����;y�_�����c��gr��@|l�T�WV� GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0  .shstrtab .interp .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .plt.got .text .fini .rodata .eh_frame_hdr .eh_frame .init_array .fini_array .dynamic .data .bss .comment                                                                                 8      8                                                 T      T                                     !             t      t      $                              4   ���o       �      �      4                             >             �      �                                 F             �      �      d                             N   ���o       4      4      @                            [   ���o       x      x      P                            j             �      �      �                            t      B       �      �                                ~             �
      �
                                    y             �
      �
      p                            �             P      P                                   �             `      `      �                             �             �      �      	                              �                           X                              �             X      X      �                              �             �      �      (                             �                                                      �                                                      �                           �                           �                         �                             �                             �E                              �             �e      �e      H                              �      0               �e      )                                                   �e      �                              