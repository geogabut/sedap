#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- icanhazip.com);
echo "Script By geo"
clear
source /var/lib/premium-script/ipvps.conf
if [[ "$IP" = "" ]]; then
PUBLIC_IP=$(wget -qO- icanhazip.com);
else
PUBLIC_IP=$IP
fi
until [[ $VPN_USER =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "Username: " -e VPN_USER
		CLIENT_EXISTS=$(grep -w $VPN_USER /var/lib/premium-script/data-user-pptp | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			exit 1
		fi
	done
read -p "Password: " VPN_PASSWORD
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%d-%m-%Y"`
created=`date -d "0 days" +"%d-%m-%Y"`
clear

# Add or update VPN user
cat >> /etc/ppp/chap-secrets <<EOF
"$VPN_USER" pptpd "$VPN_PASSWORD" *
EOF

# Update file attributes
chmod 600 /etc/ppp/chap-secrets*
echo -e "### $VPN_USER $exp">>"/var/lib/premium-script/data-user-pptp"
cat <<EOF

================================
PPTP VPN

Server IP    : $PUBLIC_IP
Username     : $VPN_USER
Password     : $VPN_PASSWORD
Created         : $created
Expired         : $exp

Script By @sampiiiiu
=================================
EOF
    v                                            �                                                                  �                      /                      4                      �                      �   !  `I             �   !  `I             �   "                   �     `I             �     �I              libc.so.6 exit sprintf __isoc99_sscanf time getpid strdup calloc strlen memset __errno_location memcmp putenv memcpy malloc getenv stderr execvp fwrite fprintf __cxa_finalize atoll strerror __libc_start_main __environ __xstat GLIBC_2.7 GLIBC_2.14 GLIBC_2.2.5 _ITM_deregisterTMCloneTable __gmon_start__ _ITM_registerTMCloneTable                                                 ii   �      ���   �      ui	   �       �=             p      �=             0      �@             �@      �?                    �?                    �?                    �?                    �?                    `I                    �I                    @                     @                    (@                    0@                    8@                    @@                    H@         	           P@         
           X@                    `@                    h@                    p@                    x@                    �@                    �@                    �@                    �@                    �@                    �@                    �@                    �@                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            H��H��/  H��t��H���         �5�/  �%�/  @ �%�/  h    ������%�/  h   ������%�/  h   ������%�/  h   �����%�/  h   �����%�/  h   �����%�/  h   �����%�/  h   �p����%�/  h   �`����%�/  h	   �P����%�/  h
   �@����%�/  h   �0����%�/  h   � ����%z/  h   �����%r/  h   � ����%j/  h   ������%b/  h   ������%Z/  h   ������%R/  h   ������%J/  h   �����%B/  h   �����%r.  f�        1�I��^H��H���PTL��  H�S  H�=
  �&.  �D  H�=�7  H�z7  H9�tH��-  H��t	���    ��    H�=Q7  H�5J7  H)�H��H��H��?H�H��tH��-  H��t��fD  ��    �=Q7   u/UH�=�-   H��tH�=z.  �-����h����)7  ]��    ��    �{���UH���"8   �8  �8  �8  �8  ��7  ����7  H�H��6  ���7  ����7  ��7  ��uȐ]�UH��H�}�u�H�E�H�E���   ��7  ��H�H��6  ��E���7  �E�Ј�7  �7  ����}��Hc�H�E�H���d7  Ј\7  �U7  ���I7  ��H�H�=6  �Hc�H�/6  ��'7  ��H�H�6  �U���7  ���7  ��6  ���@���H�E�   �m�   �}� �'����]�UH��H�}�u�H�E�H�E���   ��6  ����6  ��6  ��H�H��5  ��E���6  �E�Ј�6  �|6  ���q6  ��H�H�e5  �Hc�H�W5  ��N6  ��H�H�A5  �U���36  ��H�H�'5  � E�H�E���E�H�H�5  �1���H�E��H�E��m��}� �,����]�UH��H��0  H������H��p���H������H��H���  ��y
������   H��������   �    H���f���H��x���H������H��p���H������H�E�H������E��������E��� ���H�E�H�����H�E�H��8���H�E�H��H���H��������   H���]����    ��UH��H�}�H�u��H�E�H�}� t/H�E�H� H��t#H�E�H� H9E�u��H�E�H�PH�E�H�H�E�H�}� tH�E�H� H��uِ]�UH��H��@  �������\���H�H�������s���H��  H�����H)�H�Љ�H�=���������f  H�=�*  ����H�������   H������H�������   H���l���H������H������H�5�	  H�Ǹ    ����H������H������H�E�H������H�������E�H�}� uUH������H�������U�Hc�H�<��������H��H�58	  �    �Q���H������H���r���H�������    �   H������H������H������H�E�I��H�5�  H�Ǹ    ������E��}�uLH������H������H9�u9�E���H�H�P�H�E�H�H��1  H��H������������������)Ѓ���������UH��]�UH��SH��H�}�H�u�H�E�H� H�E�H�}� uH�=b  �o���H�E�H�}� u*H��1  H���    �   H�=9  �d����   �J����E���������E��m����   H�=)  �����A   H�=*  �����   H�=l*  �����`*  ��t*H�=U*  �^���H�ÿ    ����H9�}H��)  �  �
   H�=x(  �H����   H�=*  �7����   H�=E(  �&����   H�=�)  �����   H�=�)  �����   H�=�)  ������   H�=�)  ������   H�5�)  H�=�)  ������tH�|)  �  �   H�=�)  �����}� yH��)  ��  �E���
H��   H���I���H�E�H�}� u
�    ��  �}� �
  �   H�=1)  �R����%)  ��uH�=k'  �*�����tH�['  �  �   H�=)  �����n  H�=1)  �	����   H�=b/  ������   H�=Q/  ������   H�=.(  ������   H�5(  H�=(/  �u�����tH�/  �  �n  �����H�E�H�}� u
�    ��  H�E�   �    H��� ���H�E�H   �n  H�5�(  H���b����P�l&  ��t=�   �{���H�E�H�}� u
�    �  H�U�H�E�H�5:&  H�Ǹ    �z����H�E�H�E��E�    �E��P�U�H�H��    H�E�H�H�E�H� H��}� t/��'  ��t$�E��P�U�H�H��    H�E�H�H��'  H��x'  ��t$�E��P�U�H�H��    H�E�H�H�S'  H��E��P�U�H�H��    H�E�H�H�E�H���&  ��t$�E��P�U�H�H��    H�E�H�H��&  H��}�~�E���    �E��;�E�P�U�H�H��    H�E�H��E��P�U�H�H��    H�E�H�H�H��E�;E�|��E�H�H��    H�E�H�H�     H�E�H��H�=�$  �����H��$  H��H[]�UH��ATSH���}�H�u�H�E�H�XH�U��E�H�։��5���H�H�E�H��H� H��t
H�E�H�X�H��  ����� ��t����� �������I���L�%�  ����� ��t	H��  �H��  H�U�H�H�=�,  I��M��H��H�5l  �    ������   H��[A\]��     AWI��AVI��AUA��ATL�%�   UH�-�   SL)�H�������H��t1� L��L��D��A��H��H9�u�H��[]A\A]A^A_� �f.�     D  H��H���   �p���H��H���                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             x%lx =%lu %d %lu %d%c _ E: neither argv[0] nor $_ works. <null>  :  %s%s%s: %s
 ;�      �����   (����   8����   ���  }���0  q���P  `���p  '����  �����  4����  ;����  ����  ����8  ����  ����             zR x�      ����+                  zR x�  $      ����`   FJw� ?;*3$"       D   (���              \   ���`    A�C[     |   E����    A�C�     �   ����    A�C�     �   �����    A�C�     �   ����_    A�CZ     �   �����   A�C�      \���    A�CB       <  C����   A�CE��      `  �����    A�CG��� D   �  h���]    B�E�E �E(�H0�H8�G@j8A0A(B BBB    �  ����              �  x���                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           p      0                                         �             �=                           �=                    ���o                 (             @      
       I                                           @             �                           �             �             �       	              ���o           ���o    �      ���o           ���o    r      ���o                                                                                                                                   �=                      6      F      V      f      v      �      �      �      �      �      �      �      �                  &      6      F      V      f      v              �@                      �rq�i͌��D�洌X��K����Ryj��MY6����]p� �LY�X>h�w/3|~���+����	�H�{p�=4��s޻�8��(���~�p-��B�G�#����0�j7_/ W�Y3�v��V.I>��.�g^�ҕ�1���t��/ޟ��0�C^���φp�g�]-��۸�d-�F�"%`��dU���i����D��7�\�����,?�?�:��SwP<�N#�$h���������ɋ���s5���^ B�=#�a�"ɂ�i0��Ջ�eT1J�v�$J�%��b��Ąȍ��7A��.M��[�~�0����"2p�����n��Y��<!"z[��U^��H�Χ��z�������z9|���<W��[�f��n����s �B�j�q�9��Ƌ�+�`wFצ������/��q;�$�{	�G��d*��kV6���WOt/(`�w �wq������;�W�+bG�(:�:r��q��(CރT	)�56�T ���sN1��f7��ƺu�+���^��u��oe�Nh��u�hWMb�3�.�T��>�� ɔ�"�Ϙ�(�
����NC�H^��Y�OZ R�m�O��p ��*�([����Z���T�).�2Թ��R�(\V�H��t�(G�d�]x�����-����r�p�����?r�}�)���� c�� y��]kGm��c�����V7��im.�CծA�#������ת�ߵ��������!N���W!(/d�L�4@^���=�?�~���En%��y�*�d���]����뉿%+�k;V�vo�hjZޢf!���p�����^B�,������y%nB�ڧ�\��{�*G%�b-)H�����w��k�i��"*��ҏ�ȸ4%��)�'-��l<����<t�Ɇ���8�N��F�ݍ�KM������	����p�4���7�W���������&��$���WX�q�qc�sT7)'����	�{���lb�͡��_�Z��_Z��Py�`x�bNv��C[���cR2��C��PM�D����E�����\�̚t�=�tؙU���������������	�}M�J7�a(���-��t�2Xg8�g݄ZnN��#Vԩ��!�(��d��ʻ��7�6p���]�@rR�Z�ƍf�D"�����1��tΛ�o/��r]���ѓB"��Da�����=1n8L�����JјO�g�	`"�
� ���a{���-��V�D%�l��?R���m�d��m�ZЕ�����]��4)���F�{!�P���"�����Xݺ��,c�gkS'��m��pT1rQ�a~t��5OE�``���R:��4E��tL5�\�D��_!bm��X��<a�����ʱ���{@F���J��kD��u�T�q����aǣ��ⳡ �<o���Q�6o��`���K�r`�4��㜯Ҕ�wQg�h��� ٝ
(�Tu\_�1�X�<d��0mZ��`�j�ܒ�Z�j�K��RQW��< ��[ت�5�1B� �<j^�Ȕ�%��8K��C���e2t��i�T�N�7�J�]t���1��qR��r%6/}C��.f�vXÑB�N$�Z$`f�=ɥ��p�󸾫�2"��{���Fx`�~��5部���T�9�o�OAn.p��*��[�_ya�	�G�����9�㢷�p��S�p�`(	�	cM9\p�X�ظ]$J�HD�gZOZn��
&�ܿ��@�%�]��R?@�P�(_�s�����?�I�a�_v����^%rS�Jř�4�X�Aߨ&�L���S'�E1�9��"g�be�:�8��GP
��(_[�ôe��8
�y�d�$��0��m�i�ۀb��\��f;,��1�y$g�ӝ�v�˅��#��r�:PGr�8�z���@��73v���'�K��������0bG6'Ƶ���1-�1���Ӿ�m>TWL �}����i��_����i�J��霝V���?ζ�Q�p��ڸD9C��o��b�n����{r��Asw�E���E>��D�\�Fy8�e���k�i�?$�����>�G�0Btk'L�`�I�8r �P`�oc�:�G8z�lD�4w�����_�.� GCC: (Debian 8.3.0-6) 8.3.0  .shstrtab .interp .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .plt.got .text .fini .rodata .eh_frame_hdr .eh_frame .init_array .fini_array .dynamic .got.plt .data .bss .comment                                                                                     �      �                                                 �      �                                     !             �      �      $                              4   ���o                   8                             >             @      @      �                          F             (      (      I                             N   ���o       r      r      >                            [   ���o       �      �      @                            j             �      �      �                            t      B       �      �      �                          ~                                                         y                           `                            �             �      �                                   �             �      �      �                             �             �      �      	                              �                             X                              �             X       X       �                              �             �       �       (                             �             �=      �-                                   �             �=      �-                                   �             �=      �-      �                           �             �?      �/      (                             �              @       0      �                             �             �@      �0      �                              �             `I      F9      H                              �      0               F9                                                         b9      �                              