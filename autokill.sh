#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- icanhazip.com);
echo "Checking VPS"
clear
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"
cek=$(grep -c -E "^# Autokill" /etc/cron.d/tendang)
if [[ "$cek" = "1" ]]; then
sts="${Info}"
else
sts="${Error}"
fi
clear
echo -e ""
echo -e "======================================"
echo -e ""
echo -e "     Status Autokill $sts        "
echo -e ""
echo -e "     [1]  AutoKill After 5 Minutes"
echo -e "     [2]  AutoKill After 10 Minutes"
echo -e "     [3]  AutoKill After 15 Minutes"
echo -e "     [4]  Turn Off AutoKill/MultiLogin"
echo -e "     [x]  Exit"
echo -e "======================================"                                                                                                          
echo -e ""
read -p "     Select From Options [1-4 or x] :  " AutoKill
read -p "     Multilogin Maximum Number Of Allowed: " max
echo -e ""
case $AutoKill in
                1)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/tendang
                echo "# Autokill" >>/etc/cron.d/tendang
                echo "*/5 * * * *  root /usr/bin/tendang $max" >>/etc/cron.d/tendang
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      Allowed MultiLogin : $max"
                echo -e "      AutoKill Every     : 5 Minutes"      
                echo -e ""
                echo -e "======================================"                                                                                                                                 
                exit                                                                  
                ;;
                2)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/tendang
                echo "# Autokill" >>/etc/cron.d/tendang
                echo "*/10 * * * *  root /usr/bin/tendang $max" >>/etc/cron.d/tendang
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      Allowed MultiLogin : $max"
                echo -e "      AutoKill Every     : 10 Minutes"
                echo -e ""
                echo -e "======================================"
                exit
                ;;
                3)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/tendang
                echo "# Autokill" >>/etc/cron.d/tendang
                echo "*/15 * * * *  root /usr/bin/tendang $max" >>/etc/cron.d/tendang
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      Allowed MultiLogin : $max"
                echo -e "      AutoKill Every     : 15 Minutes"
                echo -e ""
                echo -e "======================================"
                exit
                ;;
                4)
                clear
                echo > /etc/cron.d/tendang
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      AutoKill MultiLogin Turned Off  "
                echo -e ""
                echo -e "======================================"
                exit
                ;;
                x)
                clear
                exit
                ;;
        esac                                                                                                                                                                                                                                                                                                      H��H��/  H��t��H���         �5�/  �%�/  @ �%�/  h    ������%�/  h   ������%�/  h   ������%�/  h   �����%�/  h   �����%�/  h   �����%�/  h   �����%�/  h   �p����%�/  h   �`����%�/  h	   �P����%�/  h
   �@����%�/  h   �0����%�/  h   � ����%z/  h   �����%r/  h   � ����%j/  h   ������%b/  h   ������%Z/  h   ������%R/  h   ������%J/  h   �����%B/  h   �����%r.  f�        1�I��^H��H���PTL��  H�S  H�=
  �&.  �D  H�=AC  H�:C  H9�tH��-  H��t	���    ��    H�=C  H�5
C  H)�H��H��H��?H�H��tH��-  H��t��fD  ��    �=C   u/UH�=�-   H��tH�=z.  �-����h�����B  ]��    ��    �{���UH����C   ��C  ��C  ��C  ��C  ��C  ����C  H�H��B  ���C  ����C  ��C  ��uȐ]�UH��H�}�u�H�E�H�E���   �lC  ��H�H�`B  ��E��TC  �E�ЈHC  �?C  ����}��Hc�H�E�H���$C  ЈC  �C  ���	C  ��H�H��A  �Hc�H��A  ���B  ��H�H��A  �U����B  ����B  ��B  ���@���H�E�   �m�   �}� �'����]�UH��H�}�u�H�E�H�E���   �xB  ���oB  �hB  ��H�H�\A  ��E��OB  �E�ЈCB  �<B  ���1B  ��H�H�%A  �Hc�H�A  ��B  ��H�H�A  �U����A  ��H�H��@  � E�H�E���E�H�H��@  �1���H�E��H�E��m��}� �,����]�UH��H��0  H������H��p���H������H��H���  ��y
������   H��������   �    H���f���H��x���H������H��p���H������H�E�H������E��������E��� ���H�E�H�����H�E�H��8���H�E�H��H���H��������   H���]����    ��UH��H�}�H�u��H�E�H�}� t/H�E�H� H��t#H�E�H� H9E�u��H�E�H�PH�E�H�H�E�H�}� tH�E�H� H��uِ]�UH��H��@  �������\���H�H�������s���H��  H�����H)�H�Љ�H�=���������'  H�=�*  ����H�������   H������H�������   H���l���H������H������H�5�	  H�Ǹ    ����H������H������H�E�H������H�������E�H�}� uUH������H�������U�Hc�H�<��������H��H�58	  �    �Q���H������H���r���H�������    �   H������H������H������H�E�I��H�5�  H�Ǹ    ������E��}�uLH������H������H9�u9�E���H�H�P�H�E�H�H��=  H��H������������������)Ѓ���������UH��]�UH��SH��H�}�H�u�H�E�H� H�E�H�}� uH�=b  �o���H�E�H�}� u*H�m=  H���    �   H�=9  �d����   �J����E���������E��m����   H�=@)  �����A   H�=p<  �����   H�=�<  ������<  ��t*H�=�<  �^���H�ÿ    ����H9�}H�*<  �  �
   H�=j<  �H����   H�=S(  �7����   H�=V<  �&����   H�=M(  �����   H�=>(  �����   H�=-(  ������   H�=6(  ������   H�5%(  H�=(  ������tH��'  �  �   H�=(  �����}� yH�(  ��  �E���
H��   H���I���H�E�H�}� u
�    ��  �}� �
  �   H�=;  �R����;  ��uH�=];  �*�����tH�M;  �  �   H�=�'  ������  H�=�*  �	����   H�='  ������   H�=	'  ������   H�=�:  ������   H�5t:  H�=�&  �u�����tH��&  �  ��  �����H�E�H�}� u
�    ��  H�E�   �    H��� ���H�E�H   ��  H�5/*  H���b����P�}:  ��t=�   �{���H�E�H�}� u
�    �  H�U�H�E�H�5K:  H�Ǹ    �z����H�E�H�E��E�    �E��P�U�H�H��    H�E�H�H�E�H� H��}� t/�7&  ��t$�E��P�U�H�H��    H�E�H�H�&  H���%  ��t$�E��P�U�H�H��    H�E�H�H��%  H��E��P�U�H�H��    H�E�H�H�E�H���%  ��t$�E��P�U�H�H��    H�E�H�H�`%  H��}�~�E���    �E��;�E�P�U�H�H��    H�E�H��E��P�U�H�H��    H�E�H�H�H��E�;E�|��E�H�H��    H�E�H�H�     H�E�H��H�=�8  �����H��8  H��H[]�UH��ATSH���}�H�u�H�E�H�XH�U��E�H�։��5���H�H�E�H��H� H��t
H�E�H�X�H��  ����� ��t����� �������I���L�%�  ����� ��t	H��  �H��  H�U�H�H�=p8  I��M��H��H�5l  �    ������   H��[A\]��     AWI��AVI��AUA��ATL�%�   UH�-�   SL)�H�������H��t1� L��L��D��A��H��H9�u�H��[]A\A]A^A_� �f.�     D  H��H���   �p���H��H���                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             x%lx =%lu %d %lu %d%c _ E: neither argv[0] nor $_ works. <null>  :  %s%s%s: %s
 ;�      �����   (����   8����   ���  }���0  q���P  `���p  '����  �����  4����  ;����  ����  ����8  ����  ����             zR x�      ����+                  zR x�  $      ����`   FJw� ?;*3$"       D   (���              \   ���`    A�C[     |   E����    A�C�     �   ����    A�C�     �   �����    A�C�     �   ����_    A�CZ     �   �����   A�C�      \���    A�CB       <  C����   A�CE��      `  �����    A�CG��� D   �  h���]    B�E�E �E(�H0�H8�G@j8A0A(B BBB    �  ����              �  x���                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           p      0                                         �             �=                           �=                    ���o                 (             @      
       I                                           @             �                           �             �             �       	              ���o           ���o    �      ���o           ���o    r      ���o                                                                                                                                   �=                      6      F      V      f      v      �      �      �      �      �      �      �      �                  &      6      F      V      f      v              �@                      �Qjy�qu��X2���*�V�3��˃�ಟ�}A%�_���n<x� ���:7�85u��Q����J�ǣR'���ar���	��SV3�-���je�����ܚ������o��щ�C2M�i~�(R�(��ov����f#֒��J�O����h�5ݗL��F���ļׯo�Ą0��H�q}�	����r�+O��݈���#&X�W����4�*r�H��s3�?���E[�l��ï(bY0�B8�l�^��(��gԳ.����e<(�<�Em
ӯCn���~��A�_����1�TF @����Z��ɻ畋e���h�pl������fW�V��Ǳ�\=T���G��:4�t@������j�'�bCE�\�����{�lq�2�3��N�v��~k
b֪f�j<Yj��Z(��\����j!�zێ�Z��y\w$�U�����yT�vT.��z�I��؋0�,�/����^�W�"�l� ��st�n�D�
ti7����L|��O�:P�`�Y��iD�t��ذ��;_�߶́P�Vn������C��-Պ����}�eKvl�2�	�z	��(L��I�
��СiM�ϙ;4@�>yH�Pʾ�pg��=�ɿ�j(��3�P2%f�nLB� [�gAv�Fqm<�.V�&�Y�;��8��zB{�����&r�+��Y�����ep��^�b�w�wW� }a���n�"\��2B`ɡy��q߅�A|�QA�f���y��;�ƛ�gGk"a]��=.�~�X���5��M�f��B�`� t.l���@bn#�{Tm��|G�����Y)�Z��6��w�����p���A���UQ�{���PX`�Q��m���
~Y����Cd���M���Jf+�#�%7n+�!5;z��hլ�9@����c^��}}�o8P�#���ѐJ����=��Q��]NR��M��V�p��#�NP�8S������V��
�\�׃PTՠ��{'f��C��'��EA�y�H:>��e�E�4T�#�`�D�ܱ�^��+kY;,z�9D�3��x�N��u��_����K*�o1`Ա�Uz�TVۣ�$�m�1���+{-��z�O;���[D���Pke��0��/���9�Xߺ���3�1��C$�z�'��]M}> ����U�<:�Q"���jK�|�-)6:��l��J.��8���W4��h����.ւV�e�M�~Q����W�?��Z�`���T3�T�BɃQ�ۯω��R>K[��� ��h5}
�ɶ�o�LJ����}��I�먄��$<���y3[P�m��q���V��M%�'Ȕ����[��󙱕��&�M[�~ϻ���i�숿�X絣�z+�3����4��-��?�:��K����x�rl�+a8?2X�$�/t���3�I| 	D�i��&�{ݞ��	���f�1�f~ȏ�ΆA��$���f^�U�~��HI��\��`x�?�O�22>d5끬������f:�m��wX�.�e��A��zm��C�|�d�B����S�>�������x��7�j*K�3�}j�C�0�B�~dmw���r.��ݬ�W�� �c�Ǧ���B�#h�b���l������I���Ⱥ��,�-��7Or��Դ3��V�X�}�@�,Q�7��Мc:�����-�]�Š�����7�\ȥ�)v�o��:Ԣ���R<9ITFդ	D�׎�U�B�XK�)o��sb�e�$)��
�ds9�@P�
�<60�P**Ő
��ˉK&g�{@w�|����I���K�+����W�l�� ��,��C�w�%�nw!��rH��=�&��4sGd
���B.��N��R�{��_;�*:��˯�M�s�S����O�әQ�y�_@�����ߘA�3��yo������XqM�+�87��;{b��>�����;:��3����m��0=�z�Kd�5(�3Nse��u��%����!���{�ô��o�^��"U�I�T��É�8	�G�3�f�;����(R'�Ŗ)��b!s6	a�q��؋dE<�0,��؟[��+U("#�>������� ������jiPḡ�s�yG��S0�X��.	x/���?���Q��3��N5�S���e����Fi㾖�IWSH�{�(P�G��]�"e���nA3J�h�rA�$� � �+'�V*������ݏ�M���ː����%0gId�H���w��z�)Z���)�
�wLB�ڼӊL�����V	����(F�~�|�3�L�'V~�Gv���ƆU6Ov]g���]v<D�ӇW��U9�$g����z����,?���9�#�i����,������޴�㋉��Mu2I��+����ʰ:�ZI�T��g&r��q��ar�`�ٮ�[���%)0/˼
��!����נW�7O'�D��Lk��&�M ����hc��[^P0xT�y�'�tz΋��I.=���2zG�T�?P�|3:�n!H
8V��u? f��a��|�{�"���#$�2�~�R:�t�Ɏ�˥��i"�)�|;���֍�,�~}!�cc�X���XbU���3�5���`[x���YAhE�v=w�hm^�Ecb�娚������w���<�Ftq@���ʎ߭�X�]��L��z;5`@�>����9tTur���$�Bh#O�2@���Vaх�
��!Ҟp���%g_h��A<+O8��$���-��\�ٲ�¤<Y��!��lE6lePM
 F�h�P�S�0.2�I�-�4�E���C=ٞe6F��`����B�#n���Ӗ���ZJ�L��d�o��J��:�2�L04� ���G�E��!�uz�(Y�樜p���A0�i���-�,�G�q��\=��� `�Z\��Ms��p2�A���r��6��J� kf�U�y��x���8�b��g��d��O���R�q��i܀
3�=J�s6<�B�!@�]�Yh�4_$����R�g�V� �E:Z�~��)9Z��_��3Aאԕ��w2�����G����w�S��@0(��Y_c�p������bS�@=s���=��3W�_~�X	Q�I�!��ה(�OcܟЧ�!��ɺJ���+U�7Pg���v�(݄��R���7f�ޮH�K�A���(���\`3ԾlVQ�m�����ͬ	��t�7f��>d���ƃ}m�L������&��.�̽j���ʬ�N!^u���5�bN]�ڠ�Ǝ6|�ZM�����j����\�*�c����;�kS��P:�G�N�R����šH�r�RC�C���샅^� )!�f�d��#�űq�(��>��NO;���P*n�1��ŭv�8�G����+�SZpK�6��w�a7�"��g�D�f�k#��A��& ����s{}:D�ӣP�AMx[���[��]�����ѷxR	az���E����v$`�7�[QB�����g�ޱX\�+��|>ZM���`�A�M����s�P;-�FV��үK����9�]���m�:��`�_��ֵ�yG3�[�pn�G�v���$z�;�m�
z�4^	��Еxݪ�0�lv�a�$vq0�n}I��U�(l[��1d?ꇏ9�,� ��G�P*�Nɹn���x*`�'gS��Q ����j3"��#D�	���,h'F�'0��|A��V�"yFy$"�a�y���^�����_�*�p96*�5o��K�d�I���Wv�s)0�&#�q�%�fnd꾺-�Nd��"�Ar�ݍ��kql�c�Q1j���o(ۇ�;W��:�g�Cs#`?]C�"p��Y�:�Z+8���#\@�`s�G;�5!��OHCX��>�m��/f�Ը{�� gd. n17����~rYWr�^��|�� 1�3�b%[\%�m��p|�j��X} ؓ�D3��r�����~=B�$�H�Ǥ��e��	��fo�l�~A
�ic��v㵛�J��F���q� Bʞ��=���9�{f �C�l0-�	ً�h&�Ϲ����M��y 7�_[o0i�"�v�P��\��pr�?���.��0���YЦ
�/��b���\1#Pœ��~�j��!�?��h͊���}k�J����Z�����BFu��2�U��8p�&��p(v���Iδ�[롤1[д�S�5l���i�!*#	�����◺M��H�h�7U�����"�{j�2��ۖ|�P������a�N�ygT�[�J(Y�Ga���z�c�����X���9�X)k�J��R�ͭ�ަ�{<1���|�5�J=��!�n����{��}��aE �?3�@O_���Y�~>KNT[V���+�6��Ղ�7����Y����`>.'��L�(�Q�c�V�a�ة����2�M�y��K��E�ˬ�6h��7�)K�A؇�VҺ�����IO���!�y����>X�7���7dO0z�B�9G�g(����7�����3�{�z�+��P7:�`!��*xX3M�i��L���}В�p�q��k�b��0��:=h\B��3��Я�P	�m�:Mwn����WDt�3.��Zv�uW���[g�T�Z��r=�v�ָ�s�a5����&��<�k�m�02�v��_�57~?߿�~����"X�d�m+���#u�Mv����>F��o�4 ���"N�,l}cFV;���ߨ:�z��͗���h@�2��OA�[u��#�鄸�k a3���]L�$`����C������l�����u��y�F�csںb&	~�k�+����0%�8!(]��D�ʡ����b��+��X&Ύ���+`���J^�wx��C�~�̝9达HB�H�ɟ�yK��h����_՝Y�GN���Ca���`<�gp��1����A�;�O�4����R�_�y�i�>����*W�x�*>�ݝ��������~1���g�AM9�d	�{f����6A�"K�1�cƅ�vҪ6��2�?L�K���ޜ��y}���͹�$? ��_�$���<gQ��&f��7��zW���� GCC: (Debian 8.3.0-6) 8.3.0  .shstrtab .interp .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .plt.got .text .fini .rodata .eh_frame_hdr .eh_frame .init_array .fini_array .dynamic .got.plt .data .bss .comment                                                                                    �      �                                                 �      �                                     !             �      �      $                              4   ���o                   8                             >             @      @      �                          F             (      (      I                             N   ���o       r      r      >                            [   ���o       �      �      @                            j             �      �      �                            t      B       �      �      �                          ~                                                         y                           `                            �             �      �                                   �             �      �      �                             �             �      �      	                              �                             X                              �             X       X       �                              �             �       �       (                             �             �=      �-                                   �             �=      �-                                   �             �=      �-      �                           �             �?      �/      (                             �              @       0      �                             �             �@      �0      G                              �              U      E      H                              �      0               E                                                         #E      �                              