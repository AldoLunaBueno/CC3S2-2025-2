# Actividad 5: Construyendo un pipeline DevOps con Make y Bash

Instalé la extensión WSL de VS Code para poder abrir VS Code directamente desde WSL. En lugar abrir rutas del sistema de Windows montadas dentro de WSL como /mnt/d, esta extensión permite abrir VS Code desde el mismo sistema de archivos virtual de Linux que gestiona WSL. Esto mejora notablemente el rendimiento en operaciones I/O, lo cual es muy recomendado al usar herramientas como git, python o compilar código. Para esto la ruta de mi repositorio local del curso ahora está dentro de WSL en _~/repos/CC3S2-2025-2_ y voy a estar hacieqndo desde ahí las actividades del curso siempre que sea posible para mantener un orden.

## Parte 1

### Ejercicios

**Ejercicio 1.** Ejecuta make help y guarda la salida para análisis. Luego inspecciona .DEFAULT_GOAL y .PHONY dentro del Makefile.

**Respuesta.** El comando make help imprime una lista de los objetivos definidos en el Makefile junto con su descripción. Esto se logra gracias a la regla help, que busca comentarios ## al lado de cada objetivo y los formatea en columnas. La directiva .DEFAULT_GOAL := help establece que si se ejecuta make sin argumentos, se ejecute automáticamente la regla help, mostrando la ayuda en lugar de intentar construir algo por defecto. Esto facilita al usuario entender qué tareas están disponibles. Por otro lado, .PHONY declara ciertos objetivos como "falsos" o no asociados a un archivo real, evitando conflictos si existiera un archivo con el mismo nombre en el directorio. Esto asegura que esos comandos se ejecuten siempre que se invoquen, independientemente de la presencia de archivos coincidentes.


**Ejercicio 2.** Comprueba la generación e idempotencia de build. Limpia salidas previas, ejecuta build, verifica el contenido y repite build para constatar que no rehace nada si no cambió la fuente.

**Respuesta.** En este Makefile, cada objetivo (target) está conectado a sus prerequisitos, formando un grafo dirigido de dependencias. Por ejemplo, el objetivo build depende de out/hello.txt, y este a su vez depende del archivo fuente src/hello.py. Así, la cadena de ejecución es:

```txt
src/hello.py  ->  out/hello.txt  ->  build
```

En la primera corrida de make build se observa la ejecución de los comandos. Se crea el directorio out y se genera el archivo out/hello.txt a partir de la fuente src/hello.py. En la segunda corrida, Make detecta que el archivo destino ya existe y que su marca de tiempo es más reciente que la del archivo fuente, por lo que no es necesario volver a generarlo. Esto refleja el funcionamiento del grafo de dependencias: Make compara fechas de modificación entre fuentes y productos para decidir si reconstruir. Así se garantiza la idempotencia: si nada cambió en las dependencias, la tarea no se repite innecesariamente.


**Ejercicio 3.** Fuerza un fallo controlado para observar el modo estricto del shell y .DELETE_ON_ERROR. Sobrescribe PYTHON con un intérprete inexistente y verifica que no quede artefacto corrupto.

**Respuesta.** Al forzar el fallo con PYTHON=python4, el shell entra en modo estricto gracias a las banderas -e -u -o pipefail: -e hace que cualquier error termine la ejecución inmediata, -u evita el uso de variables no definidas y -o pipefail propaga errores dentro de pipes. Esto garantiza que el error del intérprete inexistente no pase desapercibido. Además, la directiva .DELETE_ON_ERROR elimina automáticamente el archivo destino parcial (out/hello.txt), impidiendo que quede un artefacto vacío o corrupto en el sistema. De esta forma, Make asegura consistencia: si la receta falla, no quedan productos inválidos que podrían confundirse con salidas correctas en corridas posteriores.

**Ejercicio 4.** Realiza un "ensayo" (dry-run) y una depuración detallada para observar el razonamiento de Make al decidir si rehacer o no.

**Respuesta.** Despglosando:

- make -n build (dry-run) sólo lista los comandos que se ejecutarían (mkdir -p out y python3 src/hello.py > out/hello.txt) sin ejecutarlos; make -d muestra el razonamiento interno paso a paso.
- Considering target file 'build' y File 'build' does not exist indica que Make está evaluando el objetivo build; como build está declarado en .PHONY no se espera un archivo con ese nombre.
- Al Considering target file 'out/hello.txt' Make comprueba ese producto intermedio; File 'out/hello.txt' does not exist explica por qué decide reconstruirlo.
- Dentro de la comprobación Considering target file 'src/hello.py' aparece No implicit rule found — Make buscó reglas implícitas/patrón pero no las encontró, lo que es normal para un archivo fuente; No need to remake target 'src/hello.py' significa que la fuente no se genera.
- Must remake target 'out/hello.txt' es la decisión clave: por falta (o por ser más antigua) del destino, Make ejecuta la receta asociada.
- Las líneas Putting child ... on the chain, Live child, Reaping winning child y Removing child reflejan la gestión de procesos de Make: lanza la receta en procesos hijo y recoge su estado de salida.
- Successfully remade target file 'out/hello.txt' y Successfully remade target file 'build' confirman que la receta terminó sin errores y que Make marca los objetivos como actualizados.

**Ejercicio 5.** Demuestra la incrementalidad con marcas de tiempo. Primero toca la fuente y luego el target para comparar comportamientos. Comandos:

**Respuesta.** Cuando se ejecuta touch src/hello.py, la marca de tiempo de la fuente se vuelve más reciente que la del destino. Make interpreta que el archivo out/hello.txt está desactualizado respecto a su prerequisito y por eso ejecuta la receta para regenerarlo. En cambio, al hacer touch out/hello.txt lo único que cambia es la fecha del propio destino, pero sigue siendo igual o más reciente que la fuente. Por ello Make concluye que no hay trabajo pendiente y muestra "Nothing to be done for 'build'". Este comportamiento refleja el principio de incrementalidad: sólo se rehace lo estrictamente necesario cuando las dependencias han cambiado, evitando reconstrucciones innecesarias y ahorrando tiempo.

**Ejercicio 6.** Ejecuta verificación de estilo/formato manual (sin objetivos lint/tools). Si las herramientas están instaladas, muestra sus diagnósticos; si no, deja evidencia de su ausencia.

**Respuesta.** En este caso, las verificaciones manuales de estilo y formato no se ejecutaron porque las herramientas shellcheck y shfmt no estaban instaladas en el entorno. Por ello, en los archivos de log sólo aparece la confirmación de su ausencia. Estas utilidades son muy útiles: shellcheck analiza scripts bash/sh para detectar errores comunes y malas prácticas, mientras que shfmt formatea el código con estilo consistente. Para poder aprovechar sus diagnósticos se recomienda instalarlas: en sistemas basados en Debian/Ubuntu se puede usar sudo apt install shellcheck shfmt. Esto es lo que hice de inmediato.

**Ejercicio 7.** Construye un paquete reproducible de forma manual, fijando metadatos para que el hash no cambie entre corridas idénticas. Repite el empaquetado y compara hashes.

**Respuesta.** El hash obtenido en ambas corridas fue:


```txt
a5c2d43a7f927dc0bfede333961e2552d889ce3a2fe52e72e427e09980ca57c2  dist/app.tar.gz
```

La coincidencia demuestra que el paquete es reproducible. La opción --sort=name asegura que los archivos dentro del tar se ordenen de manera determinista, evitando diferencias por el orden del sistema de archivos. --mtime=@0 fija la marca de tiempo de todos los ficheros a un valor constante, eliminando variaciones por fechas. --owner=0 --group=0 --numeric-owner normalizan propietarios y grupos para que no dependan del usuario local. Finalmente, gzip -n evita incluir la fecha en la cabecera de compresión y junto a -9 fuerza compresión máxima estable. En conjunto, estas opciones eliminan fuentes de variabilidad, garantizando que el mismo contenido produzca siempre el mismo hash.

**Ejercicio 8.** Reproduce el error clásico "missing separator" sin tocar el Makefile original. Crea una copia, cambia el TAB inicial de una receta por espacios, y confirma el error.

**Respuesta.** El error "missing separator" ocurre porque Make exige que cada línea de receta empiece con un carácter de TAB, no con espacios. Esto se debe a la sintaxis histórica del programa: los objetivos y prerequisitos van sin sangría, mientras que las acciones deben estar separadas visualmente mediante TAB. Si se sustituyen por espacios, Make no los reconoce como recetas y lanza este error. Para diagnosticarlo rápidamente, basta con revisar la línea reportada en el error y confirmar si comienza con TAB o con espacios invisibles. Editores que muestran caracteres ocultos o el comando cat -A ayudan a detectar el problema con facilidad.