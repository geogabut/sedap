#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- icanhazip.com);
echo "Checking VPS"
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/shadowsocks-libev/akun.conf")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		clear
		echo ""
		echo "You have no existing clients!"
		exit 1
	fi

	clear
	echo ""
	echo "Select the existing client you want to renew"
	echo " Press CTRL+C to return"
	echo -e "==============================="
	grep -E "^### " "/etc/shadowsocks-libev/akun.conf" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
read -p "Expired (days): " masaaktif
user=$(grep -E "^### " "/etc/shadowsocks-libev/akun.conf" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/shadowsocks-libev/akun.conf" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/### $user $exp/### $user $exp4/g" /etc/shadowsocks-libev/akun.conf
clear
echo ""
echo " SS OBFS Account Has Been Successfully Renewed"
echo " =========================="
echo " Client Name : $user"
echo " Expired On  : $exp4"
echo " =========================="            �   "                   �      L             �      L              libc.so.6 exit sprintf __isoc99_sscanf time getpid strdup calloc strlen memset __errno_location memcmp putenv memcpy malloc getenv stderr execvp fwrite fprintf __cxa_finalize atoll strerror __libc_start_main __environ __xstat GLIBC_2.7 GLIBC_2.14 GLIBC_2.2.5 _ITM_deregisterTMCloneTable __gmon_start__ _ITM_registerTMCloneTable                                                 ii   �      ���   �      ui	   �       �=             p      �=             0      �@             �@      �?                    �?                    �?                    �?                    �?                     L                     L                    @                     @                    (@                    0@                    8@                    @@                    H@         	           P@         
           X@                    `@                    h@                    p@                    x@                    �@                    �@                    �@                    �@                    �@                    �@                    �@                    �@                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            H��H��/  H��t��H���         �5�/  �%�/  @ �%�/  h    ������%�/  h   ������%�/  h   ������%�/  h   �����%�/  h   �����%�/  h   �����%�/  h   �����%�/  h   �p����%�/  h   �`����%�/  h	   �P����%�/  h
   �@����%�/  h   �0����%�/  h   � ����%z/  h   �����%r/  h   � ����%j/  h   ������%b/  h   ������%Z/  h   ������%R/  h   ������%J/  h   �����%B/  h   �����%r.  f�        1�I��^H��H���PTL��  H�S  H�=
  �&.  �D  H�=):  H�":  H9�tH��-  H��t	���    ��    H�=�9  H�5�9  H)�H��H��H��?H�H��tH��-  H��t��fD  ��    �=�9   u/UH�=�-   H��tH�=z.  �-����h�����9  ]��    ��    �{���UH����:   ��:  ��:  ��:  ��:  ��:  ����:  H�H��9  ���:  ���y:  �r:  ��uȐ]�UH��H�}�u�H�E�H�E���   �L:  ��H�H�@9  ��E��4:  �E�Ј(:  �:  ����}��Hc�H�E�H���:  Ј�9  ��9  ����9  ��H�H��8  �Hc�H��8  ���9  ��H�H��8  �U����9  ����9  ��9  ���@���H�E�   �m�   �}� �'����]�UH��H�}�u�H�E�H�E���   �X9  ���O9  �H9  ��H�H�<8  ��E��/9  �E�Ј#9  �9  ���9  ��H�H�8  �Hc�H��7  ���8  ��H�H��7  �U����8  ��H�H��7  � E�H�E���E�H�H��7  �1���H�E��H�E��m��}� �,����]�UH��H��0  H������H��p���H������H��H���  ��y
������   H��������   �    H���f���H��x���H������H��p���H������H�E�H������E��������E��� ���H�E�H�����H�E�H��8���H�E�H��H���H��������   H���]����    ��UH��H�}�H�u��H�E�H�}� t/H�E�H� H��t#H�E�H� H9E�u��H�E�H�PH�E�H�H�E�H�}� tH�E�H� H��uِ]�UH��H��@  �������\���H�H�������s���H��  H�����H)�H�Љ�H�=���������  H�=�*  ����H�������   H������H�������   H���l���H������H������H�5�	  H�Ǹ    ����H������H������H�E�H������H�������E�H�}� uUH������H�������U�Hc�H�<��������H��H�58	  �    �Q���H������H���r���H�������    �   H������H������H������H�E�I��H�5�  H�Ǹ    ������E��}�uLH������H������H9�u9�E���H�H�P�H�E�H�H��4  H��H������������������)Ѓ���������UH��]�UH��SH��H�}�H�u�H�E�H� H�E�H�}� uH�=b  �o���H�E�H�}� u*H�M4  H���    �   H�=9  �d����   �J����E���������E��m����   H�=�(  �����A   H�=*  �����   H�=X*  �����L*  ��t*H�=A*  �^���H�ÿ    ����H9�}H��)  �  �
   H�=.*  �H����   H�=(*  �7����   H�=5*  �&����   H�=3  �����   H�=�)  �����   H�=�)  ������   H�=�)  ������   H�5�)  H�=y)  ������tH�i)  �  �   H�=�)  �����}� yH��)  ��  �E���
H��   H���I���H�E�H�}� u
�    ��  �}� �
  �   H�=_)  �R����S)  ��uH�=!)  �*�����tH�)  �  �   H�=()  ������  H�=�)  �	����   H�=�1  ������   H�=�1  ������   H�=�1  ������   H�5�1  H�=�1  �u�����tH��1  �  ��  �����H�E�H�}� u
�    ��  H�E�   �    H��� ���H�E�H   ��  H�5>)  H���b����P�\(  ��t=�   �{���H�E�H�}� u
�    �  H�U�H�E�H�5*(  H�Ǹ    �z����H�E�H�E��E�    �E��P�U�H�H��    H�E�H�H�E�H� H��}� t/��'  ��t$�E��P�U�H�H��    H�E�H�H��'  H���'  ��t$�E��P�U�H�H��    H�E�H�H�i'  H��E��P�U�H�H��    H�E�H�H�E�H��E0  ��t$�E��P�U�H�H��    H�E�H�H� 0  H��}�~�E���    �E��;�E�P�U�H�H��    H�E�H��E��P�U�H�H��    H�E�H�H�H��E�;E�|��E�H�H��    H�E�H�H�     H�E�H��H�=�&  �����H�~&  H��H[]�UH��ATSH���}�H�u�H�E�H�XH�U��E�H�։��5���H�H�E�H��H� H��t
H�E�H�X�H��  ����� ��t����� �������I���L�%�  ����� ��t	H��  �H��  H�U�H�H�=P/  I��M��H��H�5l  �    ������   H��[A\]��     AWI��AVI��AUA��ATL�%�   UH�-�   SL)�H�������H��t1� L��L��D��A��H��H9�u�H��[]A\A]A^A_� �f.�     D  H��H���   �p���H��H���                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             x%lx =%lu %d %lu %d%c _ E: neither argv[0] nor $_ works. <null>  :  %s%s%s: %s
 ;�      �����   (����   8����   ���  }���0  q���P  `���p  '����  �����  4����  ;����  ����  ����8  ����  ����             zR x�      ����+                  zR x�  $      ����`   FJw� ?;*3$"       D   (���              \   ���`    A�C[     |   E����    A�C�     �   ����    A�C�     �   �����    A�C�     �   ����_    A�CZ     �   �����   A�C�      \���    A�CB       <  C����   A�CE��      `  �����    A�CG��� D   �  h���]    B�E�E �E(�H0�H8�G@j8A0A(B BBB    �  ����              �  x���                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           p      0                                         �             �=                           �=                    ���o                 (             @      
       I                                           @             �                           �             �             �       	              ���o           ���o    �      ���o           ���o    r      ���o                                                                                                                                   �=                      6      F      V      f      v      �      �      �      �      �      �      �      �                  &      6      F      V      f      v              �@                      ;��J�ۼ��(�f0B�ŉW��y2��>\M�V��$wKY(U.�#Q� �	GZv�&)��b͟\��HVG$z��{w���u���� *�b�\��sf�gܾN 8���_�v1l8(�)5��-J����Z�B�¢�9�Vq�aq%�-��E��Ѭ�����Hꪋ�l.ǥ��$����Ѹ�~��B���ј�]u��=��[���<�����W��� }�+�{��:tcw���|��,��k�	����H�6mF�q��b���=�
ۢ�G��8"�J>���1TD�sm|pԭy�>���bP�n΀G+��eƲ�x,�L�dYU1l_3]|2��JsoW���.�
�gt�	d���w���J�^�1¢Ҥ���R��d)j���U�!g����g�����/����iB;�Z���V��C��p'��׸����N.C��쾜4����H���j�\�R����~��%��ӵ��rQ�)���M�"��d��<g:�����y�_-�J�/����a�F�Y�!�(b��
n��`]�w��	�9�_$l������˸�-D�8������5�m���V���+���g�((������{�hW���4ў�}+n=W��;f�d�sA]z1-C����K��my
�x(�x�7�r�n���`����Py̜�� &lş�������e�t1?�+�?5 �r�#�M-���>N3a89��^D����D{�&���|Q�4Zc!G�֤�^=�l�l��fX�\	#~�Bw�03�g� }��A�p�¯K��	��F��kJ�K�qOM:��K����3�y꽭B�`'ҟ���#um�ޙ���}�m�؉pƧ��|�a=@9��!+k.P�E�d��0/0P��Y�[Y�,����a�cRz;�q����)3ou�?���SJĢ���`��N�7�|�s.m��h�6���JC1�xP�1r��.�u�<�5��a�l�3�9����t^�G��M�.��⊝��nB/��ͳ�j鲍'���{һ���eo�_�S=ܻ�A����닟zMuL���1�0*(�E���rч}������En[��1�0hKy;q�
 �t�CQ(j��$L!^L��K�6�k��7	�0��S,����C��4P	��,U�"�~w<;!e��_�o�@��F���{�T\�}�{I�f�Xp�/[��"�H�Χ��#��,M/�b4��J����U�%y(����� \6<�(���7y��������G�֋�Է�CRRV-���G8-��0��۔�}��9Wf@_Ӂ�}���6ff�x�/��b��ֺE��0s)�h3��R_ͬ��B�)���k��GHƯ�j�>�����o��'u��c,_m8��X�Y���S<��S�gÍ�����������m���f)��mݳ�ΌC"�M0�x�������d�t�KY�ַ>��e8�}�f�g�2�~�!:�q�Y{�$P��s>���� �6H�$�JҜ�-D�6��t���E�յ�;���V��f8T$�y�?4�-�=?�	א�,���	Y��F���Ep�~���v
|MV,�0�+�ѻ���j�C��atҊ���٪P>f�U�Y�~;U'[#�<���cm����OY��AQ|!k�cǊ��
t`�!��`;���g�>CL�-�Fݑ��#h�F-4�_$�*���M��H��$܄�ɏ�ou�I8S��LP��݊��i!\"K`�h�(�d��
A}a�0G{�La/d�G��!G�]�+7���J;g<\��7W������^j`?���̖���1Y2-�����C��L�a��4*�aY�-�h����|V���MS=@� �������
J�UL��8<\���P��#kh>�q�(��3��l��2�n��������B��-�g�h�G%[�6SvE�����m1y�G��0Fɢ�m{hv
�<N�߹09�I�ѹ�����&��|��$�s��z��S�2>7)�h�D�CH��!�� ��8�p��^ޟ�S|��w��(p3��ٜ�E��G�fJH&G��VXO���p�\��'�M9��-��#�J�O��ѢV��#�\e���e֘�޲cPK�j��0S+�ݭ]�3XF2w��A���9��Ƣ��
�,*�G�4����c18@T����U�F�"����oٜo�תJ�w�x��d���Z��ՔP�'+kM7$aѴ���� �$ V.��A:�0���-�\,E�e,�̒���Mm#s?�D��\FL�R�A��/�X�2�2nl1�(�pS���)̈M�|�P_�h&βޕ�&�/�mI,���Я�b���\p�F�:���AuQ��CiKw�H�>���Ǧ��>���{#���)�.�=�9��y�eM�ݏ��9�:��z��Q����G�*۶͎	��4����V�Ow�<�Q�����Ѝ(�Z텅��h|�Jn��U"�� T~N�?����-���n���YR�/��O9�Q$�d�������/G�Vu9L��d]0�j����5��:W��G��/Th��J{�~z��z��[ s�����,R�ᝰ�Rs��(_��bt��w�11y�����)���P��s�����J����9,�&��
R&�����͝�A%)�9mW��_�u��o����Q�GϩלGt�m��z�)Ҕ1L��2�-E2S'���s���q@�.�^W��v�?
�q�[�c���y>rY~R�p�n@� >�<�@&�b{�"�[急B��� >�5
���ҬVQ	� GCC: (Debian 8.3.0-6) 8.3.0  .shstrtab .interp .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .plt.got .text .fini .rodata .eh_frame_hdr .eh_frame .init_array .fini_array .dynamic .got.plt .data .bss .comment                                                                              �      �                                                 �      �                                     !             �      �      $                              4   ���o                   8                             >             @      @      �                          F             (      (      I                             N   ���o       r      r      >                            [   ���o       �      �      @                            j             �      �      �                            t      B       �      �      �                          ~                                                         y                           `                            �             �      �                                   �             �      �      �                             �             �      �      	                              �                             X                              �             X       X       �                              �             �       �       (                             �             �=      �-                                   �             �=      �-                                   �             �=      �-      �                           �             �?      �/      (                             �              @       0      �                             �             �@      �0      -                              �              L      �;      H                              �      0               �;                                                         	<      �                              