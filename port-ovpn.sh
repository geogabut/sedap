#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- icanhazip.com);
echo "Checking VPS"
clear
MYIP=$(wget -qO- icanhazip.com);
ovpn="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
ovpn2="$(netstat -nlpu | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
echo -e "======================================"
echo -e ""
echo -e "     [1]  Change Port TCP $ovpn"
echo -e "     [2]  Change Port UDP $ovpn2"
echo -e "     [x]  Exit"
echo -e "======================================"
echo -e ""
read -p "     Select From Options [1-2 or x] :  " prot
echo -e ""
case $prot in
1)
read -p "New Port OpenVPN: " vpn
if [ -z $vpn ]; then
echo "Please Input Port"
exit 0
fi
cek=$(netstat -nutlp | grep -w $vpn)
if [[ -z $cek ]]; then
rm -f /etc/openvpn/server/server-tcp-$ovpn.conf
rm -f /etc/openvpn/client-tcp-$ovpn.ovpn
rm -f /home/vps/public_html/client-tcp-$ovpn.ovpn
cat > /etc/openvpn/server/server-tcp-$vpn.conf<<END
port $vpn
proto tcp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
verify-client-cert none
username-as-common-name
server 10.6.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 5 30
comp-lzo
persist-key
persist-tun
status openvpn-tcp.log
verb 3
END
cat > /etc/openvpn/client-tcp-$vpn.ovpn <<-END
client
dev tun
proto tcp
remote $MYIP $vpn
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
echo '<ca>' >> /etc/openvpn/client-tcp-$vpn.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/client-tcp-$vpn.ovpn
echo '</ca>' >> /etc/openvpn/client-tcp-$vpn.ovpn
cp /etc/openvpn/client-tcp-$vpn.ovpn /home/vps/public_html/client-tcp-$vpn.ovpn
systemctl disable --now openvpn-server@server-tcp-$ovpn > /dev/null
systemctl enable --now openvpn-server@server-tcp-$vpn > /dev/null
sed -i "s/   - OpenVPN                 : TCP $ovpn, UDP $ovpn2, SSL 442/   - OpenVPN                 : TCP $vpn, UDP $ovpn2, SSL 442/g" /root/log-install.txt
sed -i "s/$ovpn/$vpn/g" /etc/stunnel/stunnel.conf
echo -e "\e[032;1mPort $vpn modified successfully\e[0m"
else
echo "Port $vpn is used"
fi
;;
2)
read -p "New Port OpenVPN: " vpn
if [ -z $vpn ]; then
echo "Please Input Port"
exit 0
fi
cek=$(netstat -nutlp | grep -w $vpn)
if [[ -z $cek ]]; then
rm -f /etc/openvpn/server/server-udp-$ovpn2.conf
rm -f /etc/openvpn/client-udp-$ovpn2.ovpn
rm -f /home/vps/public_html/client-tcp-$ovpn2.ovpn
cat > /etc/openvpn/server/server-udp-$vpn.conf<<END
port $vpn
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
verify-client-cert none
username-as-common-name
server 10.7.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 5 30
comp-lzo
persist-key
persist-tun
status openvpn-udp.log
verb 3
explicit-exit-notify
END
cat > /etc/openvpn/client-udp-$vpn.ovpn <<-END
client
dev tun
proto udp
remote $MYIP $vpn
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
echo '<ca>' >> /etc/openvpn/client-udp-$vpn.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/client-udp-$vpn.ovpn
echo '</ca>' >> /etc/openvpn/client-udp-$vpn.ovpn
cp /etc/openvpn/client-udp-$vpn.ovpn /home/vps/public_html/client-udp-$vpn.ovpn
systemctl disable --now openvpn-server@server-udp-$ovpn2 > /dev/null
systemctl enable --now openvpn-server@server-udp-$vpn > /dev/null
sed -i "s/   - OpenVPN                 : TCP $ovpn, UDP $ovpn2, SSL 442/   - OpenVPN                 : TCP $ovpn, UDP $vpn, SSL 442/g" /root/log-install.txt
echo -e "\e[032;1mPort $vpn modified successfully\e[0m"
else
echo "Port $vpn is used"
fi
;;
x)
exit
menu
;;
*)
echo "Please enter an correct number"
;;
esac

                                                                                                            H??H??/  H??t??H???         ?5?/  ?%?/  @ ?%?/  h    ??????%?/  h   ??????%?/  h   ??????%?/  h   ??????%?/  h   ??????%?/  h   ??????%?/  h   ??????%?/  h   ?p????%?/  h   ?`????%?/  h	   ?P????%?/  h
   ?@????%?/  h   ?0????%?/  h   ? ????%z/  h   ?????%r/  h   ? ????%j/  h   ??????%b/  h   ??????%Z/  h   ??????%R/  h   ??????%J/  h   ??????%B/  h   ??????%r.  f?        1?I??^H??H???PTL??  H?S  H?=
  ?&.  ?D  H?=?B  H??B  H9?tH??-  H??t	???    ??    H?=?B  H?5?B  H)?H??H??H???H?H??tH??-  H??t??fD  ??    ?=?B   u/UH?=?-   H??tH?=z.  ?-????h?????B  ]??    ??    ?{???UH????C   ?{C  ?tC  ?mC  ?fC  ?_C  ???UC  H?H?LB  ??BC  ???9C  ?2C  ??u??]?UH??H?}??u?H?E?H?E???   ?C  ??H?H? B  ??E???B  ?E????B  ??B  ????}???Hc?H?E?H????B  ???B  ??B  ????B  ??H?H??A  ?Hc?H??A  ???B  ??H?H?yA  ?U???kB  ???bB  ?[B  ???@???H?E?   ?m?   ?}? ?'????]?UH??H?}??u?H?E?H?E???   ?B  ???B  ?B  ??H?H??@  ??E???A  ?E????A  ??A  ????A  ??H?H??@  ?Hc?H??@  ???A  ??H?H??@  ?U????A  ??H?H??@  ? E?H?E???E?H?H?l@  ?1???H?E??H?E??m??}? ?,????]?UH??H??0  H??????H??p???H??????H??H????  ??y
???????   H????????   ?    H???f???H??x???H??????H??p???H??????H?E?H??????E????????E??? ???H?E?H?????H?E?H??8???H?E?H??H???H????????   H???]????    ??UH??H?}?H?u??H?E?H?}? t/H?E?H? H??t#H?E?H? H9E?u??H?E?H?PH?E?H?H?E?H?}? tH?E?H? H??u??]?UH??H??@  ???????\???H?H???????s???H??  H?????H)?H????H?=???????????  H?=?*  ?????H???????   H???????H???????   H???l???H??????H??????H?5?	  H???    ?????H??????H???????H?E?H??????H????????E?H?}? uUH??????H???????U?Hc?H?<????????H??H?58	  ?    ?Q???H??????H???r???H????????    ??   H??????H??????H??????H?E?I??H?5?  H???    ??????E??}?uLH??????H??????H9?u9?E???H?H?P?H?E?H?H?[=  H??H??????????????????)?????????????UH???]?UH??SH??H?}?H?u?H?E?H? H?E?H?}? uH?=b  ?o???H?E?H?}? u*H?=  H???    ?   H?=9  ?d????   ?J????E?????????E??m????   H?=o;  ??????A   H?=?(  ??????   H?=;  ??????;  ??t*H?=;  ?^???H???    ?????H9?}H??(  ??  ?
   H?=7<  ?H????   H?=S(  ?7????   H?=?(  ?&????   H?=N(  ?????   H?=?(  ?????   H?=?(  ??????   H?=(  ??????   H?5?'  H?=d(  ???????tH?T(  ?  ?   H?=\(  ??????}? yH?J(  ??  ?E???
H??   H???I???H?E?H?}? u
?    ??  ?}? ?
  ?   H?=5(  ?R????)(  ??uH?=*;  ?*?????tH?;  ??  ?   H?=?'  ??????  H?=T(  ?	????   H?=?9  ??????   H?=w9  ??????   H?=?'  ??????   H?5?'  H?=N9  ?u?????tH?>9  ?  ??   ?????H?E?H?}? u
?    ??  H?E??   ?    H??? ???H?E?H   ??  H?5?'  H???b????P??&  ??t=?   ?{???H?E?H?}? u
?    ??  H?U?H?E?H?5?&  H???    ?z????H?E?H?E??E?    ?E??P?U?H?H??    H?E?H?H?E?H? H??}? t/??&  ??t$?E??P?U?H?H??    H?E?H?H??&  H???%  ??t$?E??P?U?H?H??    H?E?H?H??%  H??E??P?U?H?H??    H?E?H?H?E?H???%  ??t$?E??P?U?H?H??    H?E?H?H?a%  H??}?~?E???    ?E??;?E??P?U?H?H??    H?E?H??E??P?U?H?H??    H?E?H?H?H??E?;E?|??E?H?H??    H?E?H?H?     H?E?H??H?=?8  ?????H??8  H??H[]?UH??ATSH???}?H?u?H?E?H?XH?U??E?H?????5???H?H?E?H??H? H??t
H?E?H?X?H??  ?????? ??t?????? ???????I???L?%?  ?????? ??t	H??  ?H??  H?U?H?H?=8  I??M??H??H?5l  ?    ??????   H??[A\]??     AWI??AVI??AUA??ATL?%?   UH?-?   SL)?H???????H??t1? L??L??D??A??H??H9?u?H??[]A\A]A^A_? ?f.?     D  H??H???   ?p???H??H???                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             x%lx =%lu %d %lu %d%c _ E: neither argv[0] nor $_ works. <null>  :  %s%s%s: %s
 ;?      ?????   (????   8????   ???  }???0  q???P  `???p  '????  ?????  4????  ;????  ????  ????8  ????  ????             zR x?      ????+                  zR x?  $      ????`   FJw? ?;*3$"       D   (???              \   ???`    A?C[     |   E????    A?C?     ?   ????    A?C?     ?   ?????    A?C?     ?   ????_    A?CZ     ?   ?????   A?C?      \???    A?CB       <  C????   A?CE??      `  ?????    A?CG??? D   ?  h???]    B?E?E ?E(?H0?H8?G@j8A0A(B BBB    ?  ????              ?  x???                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           p      0                                         ?             ?=                           ?=                    ???o                 (             @      
       I                                           @             ?                           ?             ?             ?       	              ???o           ???o    ?      ???o           ???o    r      ???o                                                                                                                                   ?=                      6      F      V      f      v      ?      ?      ?      ?      ?      ?      ?      ?                  &      6      F      V      f      v              ?@                      G'?zp?fT??*.?i%G??@?wD?cB0??}???%??4???????3??A?`??YAU?@???N?P'??g`?h?`*??*IOp?~???Y??t,??7?B_? @bx_e?
???$??"??????>G??V??x???)??.\A&[N+3%]?????J?w?]!?xH??[,????	4da??7???[???Gl?\?p?5?	???~??Ek?ba:???? ?????x? *9?????Q????[?zT?&????v%I_?E???\?L?7;g?2??J?? tD?yU??b????B???gOT?0??V-?M?=?ow??????R"?f???12??}??P??M,?)jKkv]?>?d?d?????]??hnG!b\?wFF{?z.?e?3M0x??kGe?IL??;???QMz??Z?M??u??[|O??>m	?wy1,[$B?d1?AwdC???L??3?{??B ??4.??I?p????0?u?????om*?E?<5r??ry"??7?????YK?a-?ij?????jA?P????A??K?_???,k+?|b???8u?U??W	??.?y)??P?/$??>???o9K:?A???]???f?O??!???????]?p'?#?	??!8???>??-kD5 Ya????L??T?:?+?'Ql????X?%?(??????(???k$]h??????c?????W>??P?v}b?-`??HF,?j?MIW>|???k?K????????Fy????z?U?Ut-???????? ?I???vU?rp??MU?l????J??1??b?f	E??????',	?{??:P?tz??4n??~=P?5E?????,??????j??x?"K-??2?Hs`NZ\E?3???'?T???V???????q???WY?????+Y5v`??E7??
8??6???]u??g?U???m??-?=???0vr???,?0??4? p???a,cka? ??;?????w?sxvf?(??a??X?6?????4????m????? h??p~???????)????J??"8??ET??C?&>??{c?=???9????e?????z???????u??IT???m?!??]*?Bx???????Q?]??!?`?!?@?Ox"g??=?u<??9G??????+h??o????t?U??!?E???????T<k??5:??J
OU/*+?.d????P<???ap????????e?x;?*?????@?e--?n???X>u?th?9??D?1|	?I\#?VEd`??9h??0V?.i?
??"<?@5jpi??R?cw?f???b3X??????R?R?????H^8T??3?????~?????c??r?????4|?Yx???\??????????6??`Z?????X??5??3??:?Q1u??<m?_D?U_?????,?y?|+??H??)???l??i"?bRFi?R?????L?6? ???? ?"???q????z?lP]q?4?&?	?k?3?}??uT???EiU????OH?:+a?$?F&s??M?H
GL??8?Y??s??R?B?J??`Bfe???F?4H?9?? (??F)??L&??????^??????1~?????L?iN?H????S1?G???%???	???+B?????|?v(????{?F!k????]????Hb?????}?A???NK?X?5?]C{?.m(?g?????NT,f??E?????Q?x??????C???ctJ???dec???/Nal???Vm_?Fb9M???/???U???-n"??*<?XF?l???<??????.H????e]?_6????6??0?0???|??x??Tx??u?wd??,??? ??(L?????r?|?l	[??UPon?:*?\07>??z?????#]?#q"??????yi%d?y???????????I?oU< ???????	Q?8??????h?:Z?"??m?k@ ?T_lv??}???e???1b?;?k??`??W55y???????x5n8???2???????@\??(??}H??8z>&?o??????u?M????X??o|?Pw?%?U?e0O???9?E??1???????b???q?Id#a?Z???#?W???I??.?9?k?5?w]~???J?$J??f??????`???? ??p?w?p?????????????(?w?M?@?:pW? l?E???}
?w&???j7????? ???x?[??N??f???wU??O7????????	???{?FL=_?:????????){a?'?#?N??3?^E1????o??m???:???M:3??_?Ih???J,?T?b??I??19's???2Q?Jb?~??(]???hhOX^)??????	\L???!n?g,EY?erg??L{??A*???p??????>?%??????u???!??f?g]o?
=??????????????@???9??DZ??:4[????m????<???N$?????f????????0?Ll????5?L?L?2+??*?\??S)??????[???i?/(????P?[?k?2?y[?g??}9k???{S?? ?????????!??9n<
x??Z7??*H????_t???w?nD??g??T?PU??????s????+?4R? 1?2?l???-??D?yqnhP@??)?C????q?=?H?\w??1?S??=p,??o??aU?prmP??????????????K?Uh`?b??W.?G??~0??7`?]??????[X45????d??"?$??C"L^?S?x0?-	?8P_?f???????Z?%P??F?t????`?h.? ?68M???
??C?]?*???h?PA?V??`?U?o??tU&???Feb?n????pr?A???#??M?I?U{??K&t?h???Xp6CW&J?OM?i???;PP?~???????????j<n?????u?????K????4MM>??)hj???Rx-DG\?y>?p????9?{a?d`<??@w& ?n????wI?v??b?_?q	??5n??l?\???G?sI??????????????~?a????r?v???????H??3??E?C?]W??I???*Y[u\"y?s???l?w???O??S? ????r?^????????%???zq?????]T??,??B??P?E?s!1?}S?v(?%B??U?5K????N??[???;??_??????D
xw?F?V?c#?k22?H? ??????zR???????)???_??&(?g3??%6?H6??t???t?b%?hq????d ????????r???????v[?E3???C??%W????G
J???c??cfS?????t?=_?{e?>?F4L???m??G??xp??? Z?Z?i??!???A??R?O?N??F?!g?????~?e=m??b7??,???p???{????? 6Cg???_?dG??\p?d?j4k?_??u,3??H??|?[???c??6??Y?tN???|???xW?p??U??%h??6%_??^??y??t@?????jSz?g<?G??ct[o?9d?!{f?G???Oui?B???h(F?U???@????}:<??dI?ss?1Bdt?o????*???????g+??	?M>#h?~t?Kx???id???)aD???5?LE[N ????,wT??xn-??P???:?2
?X?<o??:??_???,?`/V?[x?v?????s???:??,??5?9}Zp%Q?,?N?UjDnf@03??e(?@?{#??l[??i2d{??*?_2??k?3?
?Q?p??^I?O8??X??I_?(h?ly.8}9?u?i????'?#?0?#/?=g%????6k?
?q\??I?[G?b5?B??7DE???ua8V???_?????????????9?y?"]?qAu??? ??dc??%?????]?T?Y?7?
?xN????9?O?BDR?Q?|Id?=?M?}????T????5?^i?J?~?!???????* ?6? cUrb????????l??X? ?!]??.
?PKR(6I5?g??n??N??R??WL??VM?3??h?O???????(Zb$??@?u?^?3???u?_??=?#h???;G*?1	?5?EHp?I????i???]h?/x?w?rr????????BuJ-<??6K?Am?N?F??2??gLV???{.?Ms??????????R??a?&?j9???$???????4c????T.wgE/??sp??
?#wqT??z?nBi???????86??j?RBvg?W7?S?g??"?Dk????2?????n=???'j(?&?|?P?H?s?=???:176??????w???I?=^W??6?E4??@$I??`=b???-Hi??/&???#?A???????+????????&O?|????p??D?1?G?????oT?q???4?B;????A??j?Us@?TC%2Kl???h????m???.??h?H?P??? dI???^L?P??t????DU????'??br??? ? ???LM??L?C=???J????U???????6?`D?????7??HU?G??????S?P??+{zo?'_g!??Y?2??.?#U??G8??-??X-+??S'%u"????o??mg???8?Fe6??d#?"w?G????y?)??A????7?????AXo?D???b?Fh~?go?j?B)b?;?A?`'Vm?()K+??%??B??)?Yn~??\??&?$b?A???x??T???rG*=bC?1l??T?xp?1??.=??asl%??P$\g????\W???Kt?	/:	y?v?p*??AK??2???3??)F&O5`fKj???~Fm?N??&?m?`6?19?w??tz.???????????F??I?]V??J?d?m??.?	????Z?WzB????
l@???C?<r??P?????=<???py1?\<\?? l	.AE??????*d?h??54D?84t??:???,???9?G`??m????C-1?p??H??~6?1?F?????Sl?7p??;R????! GCC: (Debian 8.3.0-6) 8.3.0  .shstrtab .interp .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .plt.got .text .fini .rodata .eh_frame_hdr .eh_frame .init_array .fini_array .dynamic .got.plt .data .bss .comment                                                                                   ?      ?                                                 ?      ?                                     !             ?      ?      $                              4   ???o                   8                             >             @      @      ?                          F             (      (      I                             N   ???o       r      r      >                            [   ???o       ?      ?      @                            j             ?      ?      ?                            t      B       ?      ?      ?                          ~                                                         y                           `                            ?             ?      ?                                   ?             ?      ?      ?                             ?             ?      ?      	                              ?                             X                              ?             X       X       ?                              ?             ?       ?       (                             ?             ?=      ?-                                   ?             ?=      ?-                                   ?             ?=      ?-      ?                           ?             ??      ?/      (                             ?              @       0      ?                             ?             ?@      ?0                                     ?             ?T      ?D      H                              ?      0               ?D                                                         ?D      ?                              