#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- icanhazip.com);
echo "Checking VPS"
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/v2ray/config.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo ""
		echo "You have no existing clients!"
		exit 1
	fi

	clear
	echo ""
	echo " Select the existing client you want to remove"
	echo " Press CTRL+C to return"
	echo " ==============================="
	echo "     No  Expired   User"
	grep -E "^### " "/etc/v2ray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
user=$(grep -E "^### " "/etc/v2ray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/v2ray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/^### $user $exp/,/^},{/d" /etc/v2ray/config.json
sed -i "/^### $user $exp/,/^},{/d" /etc/v2ray/none.json
rm -f /etc/v2ray/$user-tls.json /etc/v2ray/$user-none.json
systemctl restart v2ray
systemctl restart v2ray@none
clear
echo " V2RAY Account Deleted Successfully"
echo " =========================="
echo " Client Name : $user"
echo " Expired On  : $exp"
echo " =========================="            4                      �                      �   !  �K             �   !  �K             �   "                   �     �K             �     �K              libc.so.6 exit sprintf __isoc99_sscanf time getpid strdup calloc strlen memset __errno_location memcmp putenv memcpy malloc getenv stderr execvp fwrite fprintf __cxa_finalize atoll strerror __libc_start_main __environ __xstat GLIBC_2.7 GLIBC_2.14 GLIBC_2.2.5 _ITM_deregisterTMCloneTable __gmon_start__ _ITM_registerTMCloneTable                                                 ii   �      ���   �      ui	   �       �=             p      �=             0      �@             �@      �?                    �?                    �?                    �?                    �?                    �K                    �K                    @                     @                    (@                    0@                    8@                    @@                    H@         	           P@         
           X@                    `@                    h@                    p@                    x@                    �@                    �@                    �@                    �@                    �@                    �@                    �@                    �@                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            H��H��/  H��t��H���         �5�/  �%�/  @ �%�/  h    ������%�/  h   ������%�/  h   ������%�/  h   �����%�/  h   �����%�/  h   �����%�/  h   �����%�/  h   �p����%�/  h   �`����%�/  h	   �P����%�/  h
   �@����%�/  h   �0����%�/  h   � ����%z/  h   �����%r/  h   � ����%j/  h   ������%b/  h   ������%Z/  h   ������%R/  h   ������%J/  h   �����%B/  h   �����%r.  f�        1�I��^H��H���PTL��  H�S  H�=
  �&.  �D  H�=�9  H��9  H9�tH��-  H��t	���    ��    H�=q9  H�5j9  H)�H��H��H��?H�H��tH��-  H��t��fD  ��    �=q9   u/UH�=�-   H��tH�=z.  �-����h����I9  ]��    ��    �{���UH���B:   �;:  �4:  �-:  �&:  �:  ���:  H�H�9  ��:  ����9  ��9  ��uȐ]�UH��H�}�u�H�E�H�E���   ��9  ��H�H��8  ��E���9  �E�Ј�9  ��9  ����}��Hc�H�E�H����9  Ј|9  �u9  ���i9  ��H�H�]8  �Hc�H�O8  ��G9  ��H�H�98  �U���+9  ���"9  �9  ���@���H�E�   �m�   �}� �'����]�UH��H�}�u�H�E�H�E���   ��8  ����8  ��8  ��H�H��7  ��E���8  �E�Ј�8  ��8  ����8  ��H�H��7  �Hc�H�w7  ��n8  ��H�H�a7  �U���S8  ��H�H�G7  � E�H�E���E�H�H�,7  �1���H�E��H�E��m��}� �,����]�UH��H��0  H������H��p���H������H��H���  ��y
������   H��������   �    H���f���H��x���H������H��p���H������H�E�H������E��������E��� ���H�E�H�����H�E�H��8���H�E�H��H���H��������   H���]����    ��UH��H�}�H�u��H�E�H�}� t/H�E�H� H��t#H�E�H� H9E�u��H�E�H�PH�E�H�H�E�H�}� tH�E�H� H��uِ]�UH��H��@  �������\���H�H�������s���H��  H�����H)�H�Љ�H�=����������
  H�=�*  ����H�������   H������H�������   H���l���H������H������H�5�	  H�Ǹ    ����H������H������H�E�H������H�������E�H�}� uUH������H�������U�Hc�H�<��������H��H�58	  �    �Q���H������H���r���H�������    �   H������H������H������H�E�I��H�5�  H�Ǹ    ������E��}�uLH������H������H9�u9�E���H�H�P�H�E�H�H�4  H��H������������������)Ѓ���������UH��]�UH��SH��H�}�H�u�H�E�H� H�E�H�}� uH�=b  �o���H�E�H�}� u*H��3  H���    �   H�=9  �d����   �J����E���������E��m����   H�= 2  �����A   H�=�(  �����   H�=�)  �����y)  ��t*H�=n)  �^���H�ÿ    ����H9�}H��(  �  �
   H�=A)  �H����   H�=;)  �7����   H�=[(  �&����   H�=�(  �����   H�=�(  �����   H�=�(  ������   H�=�(  ������   H�5�(  H�=q(  ������tH�a(  �  �   H�=�(  �����}� yH�x(  ��  �E���
H��   H���I���H�E�H�}� u
�    ��  �}� �
  �   H�=H(  �R����<(  ��uH�=4(  �*�����tH�$(  �  �   H�=�'  �����m  H�=�)  �	����   H�=@0  ������   H�=/0  ������   H�=�&  ������   H�5�&  H�=0  �u�����tH��/  �  �m  �����H�E�H�}� u
�    ��  H�E�   �    H��� ���H�E�H   �m  H�5�(  H���b����P��&  ��t=�   �{���H�E�H�}� u
�    �  H�U�H�E�H�5P&  H�Ǹ    �z����H�E�H�E��E�    �E��P�U�H�H��    H�E�H�H�E�H� H��}� t/�m&  ��t$�E��P�U�H�H��    H�E�H�H�H&  H���&  ��t$�E��P�U�H�H��    H�E�H�H�|&  H��E��P�U�H�H��    H�E�H�H�E�H���%  ��t$�E��P�U�H�H��    H�E�H�H��%  H��}�~�E���    �E��;�E�P�U�H�H��    H�E�H��E��P�U�H�H��    H�E�H�H�H��E�;E�|��E�H�H��    H�E�H�H�     H�E�H��H�=�%  �����H��%  H��H[]�UH��ATSH���}�H�u�H�E�H�XH�U��E�H�։��5���H�H�E�H��H� H��t
H�E�H�X�H��  ����� ��t����� �������I���L�%�  ����� ��t	H��  �H��  H�U�H�H�=�.  I��M��H��H�5l  �    ������   H��[A\]��     AWI��AVI��AUA��ATL�%�   UH�-�   SL)�H�������H��t1� L��L��D��A��H��H9�u�H��[]A\A]A^A_� �f.�     D  H��H���   �p���H��H���                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             x%lx =%lu %d %lu %d%c _ E: neither argv[0] nor $_ works. <null>  :  %s%s%s: %s
 ;�      �����   (����   8����   ���  }���0  q���P  `���p  '����  �����  4����  ;����  ����  ����8  ����  ����             zR x�      ����+                  zR x�  $      ����`   FJw� ?;*3$"       D   (���              \   ���`    A�C[     |   E����    A�C�     �   ����    A�C�     �   �����    A�C�     �   ����_    A�CZ     �   �����   A�C�      \���    A�CB       <  C����   A�CE��      `  �����    A�CG��� D   �  h���]    B�E�E �E(�H0�H8�G@j8A0A(B BBB    �  ����              �  x���                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           p      0                                         �             �=                           �=                    ���o                 (             @      
       I                                           @             �                           �             �             �       	              ���o           ���o    �      ���o           ���o    r      ���o                                                                                                                                   �=                      6      F      V      f      v      �      �      �      �      �      �      �      �                  &      6      F      V      f      v              �@                      �([Iz���m�&L`l.@�y�\%`�97Xr~q���{�Uէ�q�@d�i�k��nڕ=�b̨+����� �f���F��4.�7�p�gFy���5#��ֻ��w!������
5�g;��4=8ߍG&�x���m3���"��)mp�]4Y��,�/�d�w9v�����o��&8
��|+{3�O~ZU�*U��F$3,���BS��>��O�)+��R�����e<�+���,@�@P��{�H�7.����� F�b�p3�u^�q��&��K~6y0H�����{��P �������� ��4��}��P��j���d�{b����9��73���R��p]W�o)������#�ķL�_ݲ{�w���Z�,�'�5�%G�]�����hͲ�Y)D��������g��aT���Lgsh�5ſ��>���rٚ=�~&�����D�ۑN�2*/���(����Cg\���B��f���C@�-��U�d[���u6�1E~����i� E5�r3e���#\�6L8lP����bj�Fө;��p�a�)*i�M��l��hh��2�a�j�p�eS)d�S�aH�'I#,����V�j���ԁ@��j<;�/�W�{F��|�pJ�f������]�
x$�X�	o�C�h��٥T�9��������Q��8M�{� ���������
��^�8;P �D�:o�*�Jm�ܠW3A�³н7^�))}du�N7�`��amYiq�4��u��1"z1x���wgم���NT��B㋨���2"��J~Ç����)��ϛ��׫U�_!���wӾo�j檸�^��q���|I�>e�4�x<�P_8�Uv���wsS6δ��RY�aMEVA�q]N�"ňR��~�9�(W�o�S� �X�Ž]�tk�K�������=�#|H�w�2�(aBi�� ���vI 1$���i=��"C���۾�S�����ɀpt����d`�y��nP�=�ng�z�?�ֿ��0Ⱦ-C���W��r�����y�uD�Ƿz2��!�䁢�$º�ⴽ��s�U�U����*~R�˃�������w��'~d�h-��v���"Co�1�����H��N��w��(�X�eV o��zY���V�ϐ�W��=6��$_;.�E�`�>eV��+>PJ1w�Ԃ��c.�C��}�6&塮�CY�mT�����j3��l�mѣ�	�gx�Fg�� �N{����`�W�,f�c0�|�p$�BtM�-�iu�o�gxC��Ī�av�N��|g����C�(�F��1�d)f��ȍ�,6���Ó�ީ�Q5.�[�6ia{�y�ٕ��E�I*�������L���2J/�J����蝭�}��V�;ж��'�D[|F����}	�\��~^���ff��,�Df�)r�4T�%a2�c:�9����l�,W���5���=�i��y\�XJИ��ښ8�U����B⠬�1��~�4��
��K�Y�ܥ��C������� T��[�_wsH͗�_�2q�:�-Bf��X8���K��\��˲;�n����[i9��gF��� �L�|�T�E���)���Y|�`��+R��������BE���z5��y�E�Sfr->�
 q�Fi�˾1���m�` ^�d�����%�Lv �5�Ɨ����"D�o�'\l��`ƒ�!���y���V�Ҥ<I�TC�A��H%@�=�8xb-Ă���AD~*��*�A��7S�
?�Άz��#�ց������6�W�Z|JOk�����7����|���ʤ���x'1" Ҟ��l}�Ub�_Ӝ���m�fYO�.6�� m[4UU��;�s.��k���v�Ab3��.@��X_.p`
e��W��ʇ�˱W��5^?�sJ��P�N[*7.I�ī{���Z]1b���8iIWŇȧ�k;�&�(R ����ij���c�ac�5;
�	B"�����o����/H�h�m,3ᬝj#�z b�5p�	��UߌL���z��u���s��|Hl�
WJ���H0$��H��U�A�Zy��gt�+;�I��50��EXG�4��a'^�j턕#f��Q���d"���G��L�#،�#����޽v۷ȗAͼ5��:��f���[�A�tk=��J�C�E �Y�jQ�K�L�(��/D���E�ksك`��<q+���ֱ��iZN�S���s�e��c��󦕖��\K��ppUcX�y;ieU��\:�*�eY��,_�3;_ͬ��^o����R���$�Q~�_/`[kC���\SLf��~Z��G�z�����y��+vO5<G�9n�D�F��W�2�M�ܰ�_ٔ�9��d�K~��x{��'�r�t�Q�v��OE��M)l�06��ė'@tg���BZ���z\�ʡCR�m�����L�5s���b4m<v�0{t��И�r�aH��Ǡ2�զ}�.ߴ�+dL��;���]�q~�C��!���
w��+�W�R����fa��i	��縣�E��P�:<@����� -�&�����=���{;[(�m�Ū�>���t���:#)ʹ�j����i"��pLrxX�)N�&�J�אHV��'���=�v`��/�kA����m�D��r�����}��oC=� GCC: (Debian 8.3.0-6) 8.3.0  .shstrtab .interp .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .plt.got .text .fini .rodata .eh_frame_hdr .eh_frame .init_array .fini_array .dynamic .got.plt .data .bss .comment                                                                               �      �                                                 �      �                                     !             �      �      $                              4   ���o                   8                             >             @      @      �                          F             (      (      I                             N   ���o       r      r      >                            [   ���o       �      �      @                            j             �      �      �                            t      B       �      �      �                          ~                                                         y                           `                            �             �      �                                   �             �      �      �                             �             �      �      	                              �                             X                              �             X       X       �                              �             �       �       (                             �             �=      �-                                   �             �=      �-                                   �             �=      �-      �                           �             �?      �/      (                             �              @       0      �                             �             �@      �0      �
                              �             �K      d;      H                              �      0               d;                                                         �;      �                              