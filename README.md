# detached.sh
Este script está diseñado para evitar que comandos y procesos queden a medio ejecutar cuando se trabaja en una conexión SSH. Es común que, al perder la conexión SSH, los procesos asociados a la sesión se detengan, lo que puede ser problemático para tareas largas o críticas. Este script ofrece una solución flexible para ejecutar comandos de manera segura, ya sea en segundo plano con `nohup`, en una sesión persistente de `screen`, o para manejar procesos ya en ejecución.

---

**Instrucciones de uso**

**Sintaxis básica**

> `bash`
> ```bash
> ./detached.sh [opciones] [comando]
> ```

**Opciones disponibles**

| Opción| Descripción|
|:-----------------|:----------------|
|  `--screen`  |	Ejecuta el comando en una sesión de screen para persistencia.  |
|  `--log`  |	Guarda la salida del comando en un archivo de log predeterminado (output.log).  |
|  `--log-file=nombre.log`  |	Guarda la salida del comando en un archivo de log con el nombre especificado.  |
|  `--pid=numero-proceso`  |	Mueve un proceso existente a segundo plano y lo desvincula con disown.  |
|  `--trace[=numero-proceso]`  |	Muest la salida del archivo de registro o del proceso especificado.  |

**Ejemplos de uso**

1. Ejecutar un comando con nohup (sin log):
```
./detached.sh sleep 100
```
2. Ejecutar un comando con nohup y guardar log en output.log:
```
./detached.sh --log sleep 100
```
3. Ejecutar un comando con nohup y guardar log en un archivo específico:
```
./detached.sh --log-file=mi_log.log sleep 100
```
4. Mover un proceso existente a segundo plano con disown:
```
./detached.sh --pid=12345
```
5. Ejecutar un comando en una sesión de screen:
```
./detached.sh --screen sleep 100
```
6. Muestra la salida del archivo de registro:
```
./detached.sh --trace
```
6. Muestra la salida del proceso con PID 12345:
```
./detached.sh --trace=12345
```

**Motivación**
El script fue creado para resolver el problema común de perder procesos largos o críticos cuando se trabaja en una conexión SSH inestable. Al usar nohup, screen, o disown, puedes asegurarte de que los comandos sigan ejecutándose incluso si la conexión SSH se interrumpe. Esto es especialmente útil para tareas como compilaciones largas, entrenamientos de modelos de machine learning, o cualquier proceso que no deba detenerse abruptamente.

**Contribuciones**
Si encuentras algún problema o tienes sugerencias para mejorar el script, no dudes en abrir un issue o enviar un pull request. ¡Tu contribución es bienvenida!

**Licencia**
Este script se distribuye bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.

