# Limitar conexiones. Por ejemplo sirve para mitigar ataques slowloris
iptables -I INPUT -p tcp --dport 443 -m connlimit --connlimit-above 20 --connlimit-mask 40 -j DROP
iptables -I INPUT -p tcp --dport 443 -m connlimit --connlimit-above 20 --connlimit-mask 40 -j DROP
iptables -A INPUT -p tcp -m connlimit --connlimit-above 20 -j REJECT --reject-with tcp-reset

# Limitar si la IP intenta mas de 20 conexiones en menos de 30 segundos. Dejo varios ejemplos comentados.
iptables -I INPUT -p tcp --dport 443 -m state --state NEW -m recent --set
iptables -I INPUT -p tcp --dport 443 -s 111.111.11.1/24 -m state --state NEW -m recent --update --seconds 30 --hitcount 20 -j DROP
iptables -A INPUT -p tcp --dport 443 -m state --state NEW -m recent --update --seconds 5 --hitcount 3 -j DROP

# Bloquear trafico por cantidad de conexiones por unidad de tiempo.
# Maximo 50 conexiones por segundo, con una rafaga de 18 conexiones entre segundos
iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 50/s --limit-burst 18 -j ACCEPT 
iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP

# Bloquear paquetes invalidos. Aquellos que no sean paquetes SYN (de establecimiento de conexión)
iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

# Bloquear paquetes nuevos que no son SYN. No pertenecen a ninguna conexión establecida, y ademas no usan el flag SYN.
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

# Bloquear valores anoramales de MSS. Aquellos que contengan el flag SYN activado, pero que ademas tengan un valor 
# de MSS (Maximum Segment Size) fuera de lo normal, ya que los paquetes SYN suelen ser pequeños, y paquetes SYN grandes
# podrían indicar inundacian de SYN (SYN flood).
iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

# Bloquear paquetes con flags erroneos
# Algunas reglas para filtrar paquetes con flags erróneos, aquellos flags o combinaciones de los mismos que un 
# paquete normal no utilizaria.
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

# Bloqueamos todo el trafico ICMP entrante. Bloquea el ping y ataques ping de la muerte entre otros. 
iptables -t mangle -A PREROUTING -p icmp -j DROP

# Bloquear paquetes fragmentados
# Normalmente no es necesario, pero a veces la inundacion de paquetes UDP fragmentados pueden consumir mucho 
# ancho de banda y producir una denegacion de servicio
iptables -t mangle -A PREROUTING -f -j DROP

# Mitigar escaneos de puertos
iptables -N port-scan 
iptables -A port-scan -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 3 -j RETURN 
iptables -A port-scan -j DROP