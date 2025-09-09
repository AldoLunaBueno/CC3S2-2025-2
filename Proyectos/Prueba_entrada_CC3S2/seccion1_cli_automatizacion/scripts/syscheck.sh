#!/usr/bin/env bash
set -euo pipefail
trap 'echo "[ERROR] Falló en línea $LINENO" >&2' ERR

mkdir -p reports

# TODO: HTTP-guarda headers y explica código en 2-3 líneas al final del archivo
{
  echo "curl -I example.com"
  curl -Is https://example.com | sed '/^\r$/d'
  echo
  echo "El Código HTTP 200 significa que el servidor recibió y procesó correctamente la petición.
El header cache-control especifica la política de cacheo del navegador,
y su directiva max-age indica cuántos segundos tarda en expirar una copia en caché del recurso solicitado."
} > reports/http.txt

# TODO: DNS — muestra A/AAAA/MX y comenta TTL
{
  echo "A";    dig A example.com +noall +answer
  echo "AAAA"; dig AAAA example.com +noall +answer
  echo "MX";   dig MX example.com +noall +answer
  echo
  echo "Un TTL bajo puede ser una carga considerable para el servidor DNS autorizado, ya que la copia cacheada expira muy rápido y el servidor de cacheo necesita consultar al servidor DNS con mucha frecuencia. También puede aumentar un poco la latencia, ya que cuando la copia cacheada expira es necesaria una búsqueda DNS que tarda unos 100 ms (mucho más que cuand ose cuenta con la copia cacheada), y con TTL bajo esto sucede frecuentemente. Pero un TTL bajo puede ser útil para servicios críticos que cambian de dirección. Un TTL alto aumenta el performance reduciendo la frecuencia de búsquedas DNS, pero también retrasa la propagación de cambios de los registros DNS. Por ejemplo, un TTL de 18474 como el del registro MX de example.com quiere decir que los cambios en este registro DNS tardan en propagarse unas 5 horas."
} > reports/dns.txt

# TODO: TLS - registra versión TLS
{
  echo "TLS via curl -Iv"
  curl -Iv https://example.com 2>&1 | sed -n '1,20p'
} > reports/tls.txt

# TODO: Puertos locales - lista y comenta riesgos
{
  echo "ss -tuln"
  ss -tuln || true
  echo
  echo "Los puertos abiertos innecesariamente exponen al sistema a ataques de denegación de servicio, fugaz de información e integridad comprometida. Se recomienda cerrar los servicios no requeridos y limitar el acceso con firewall a las interfaces que realmente sean necesarias. Listamos los puertos y sus riesgos:
  Puerto 53: Usado para resolucíon de nombres. Puede ser explotado por ataques de amplificación DDoS.
  Puerto 67: Usado por servidores DHCP. Un atacante puede enviar respuestas falsas y realizar ataques spoofing."
} > reports/sockets.txt

echo "Reportes generados en ./reports"
