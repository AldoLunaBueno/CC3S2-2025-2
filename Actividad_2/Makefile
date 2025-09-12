SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
all: prepare run hosts-setup dns-demo http-checks tls-cert nginx tls-checks logs-pipeline table

prepare: ; ./Respuestas-actividad2.sh prepare
run:     ; ./Respuestas-actividad2.sh run
hosts-setup: ; ./Respuestas-actividad2.sh hosts-setup
dns-demo: ; ./Respuestas-actividad2.sh dns-demo
http-checks: ; ./Respuestas-actividad2.sh http-checks
tls-cert: ; ./Respuestas-actividad2.sh tls-cert
nginx: ; ./Respuestas-actividad2.sh nginx
tls-checks: ; ./Respuestas-actividad2.sh tls-checks
logs-pipeline: ; ./Respuestas-actividad2.sh logs-pipeline
systemd: ; ./Respuestas-actividad2.sh systemd
stop: ; ./Respuestas-actividad2.sh stop
clean: ; ./Respuestas-actividad2.sh clean
table: ; ./Respuestas-actividad2.sh table

.PHONY: all prepare run hosts-setup dns-demo http-checks tls-cert nginx tls-checks logs-pipeline systemd stop clean table
