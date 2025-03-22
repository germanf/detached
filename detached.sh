#!/bin/bash

# Función para mostrar ayuda
usage() {
    echo "Uso: $0 [--screen] [--log] [--log-file=nombre-archivo] [--pid=numero-proceso] [--trace[=PID]] comando"
    exit 1
}

# Variables
USE_SCREEN=0
LOG_OUTPUT=0
LOG_FILE=""
PID=""
COMMAND=""
TRACE=""

# Procesar argumentos
while [[ $# -gt 0 ]]; do
    case "$1" in
        --screen)
            USE_SCREEN=1
            shift
            ;;
        --log)
            LOG_OUTPUT=1
            LOG_FILE="output.log"
            shift
            ;;
        --log-file=*)
            LOG_OUTPUT=1
            LOG_FILE="${1#*=}"
            shift
            ;;
        --pid=*)
            PID="${1#*=}"
            shift
            ;;
        --trace*)
            TRACE="${1#*=}"
            shift
            ;;            
        *)
            COMMAND="$*"
            break
            ;;
    esac
done

# Validar que se haya proporcionado un comando
if [[ -z "$COMMAND" && -z "$PID" && -z "$TRACE"]]; then
    echo "Error: Debes proporcionar un número de proceso para --pid o un comando."
    usage
fi

# Caso 1: Si se proporciona --pid
if [[ -n "$PID" ]]; then
    if kill -0 "$PID" 2>/dev/null; then
        echo "Moviendo el proceso $PID a segundo plano..."
        kill -CONT "$PID"  # Reanudar el proceso si estaba suspendido
        bg %1 2>/dev/null  # Mover a segundo plano (asume que es el trabajo 1)
        disown "$PID" 2>/dev/null # Desvincular el proceso de la sesión actual
        echo "Proceso $PID desvinculado y en segundo plano."

        # Redirigir la salida si se especificó --log o --log-file
        if [[ "$LOG_OUTPUT" -eq 1 ]]; then
            if [[ -n "$LOG_FILE" ]]; then
                echo "Redirigiendo salida a $LOG_FILE..."
                # Redirigir la salida del proceso a un archivo
                tail -f /proc/$PID/fd/1 > "$LOG_FILE" 2>&1 &
            else
                echo "Redirigiendo salida a output.log..."
                # Redirigir la salida del proceso a output.log
                tail -f /proc/$PID/fd/1 > output.log 2>&1 &
            fi
        fi
    else
        echo "Error: El proceso con PID $PID no existe."
        exit 1
    fi

# Caso 2: Si se proporciona --screen
elif [[ "$USE_SCREEN" -eq 1 ]]; then
    echo "Ejecutando comando en una sesión de screen..."
    screen -dmS mysession bash -c "$COMMAND"
    # Obtener el PID de la sesión de screen
    PID=$(ps -o pid= -C screen --ppid $$ | grep -m 1 "screen" | awk '{print $1}')
    echo "Comando ejecutado en la sesión de screen 'mysession'. Usa 'screen -r mysession' para reconectar."
    
# Caso 3: Ejecución normal con nohup
else
    if [[ "$LOG_OUTPUT" -eq 1 ]]; then
        if [[ -n "$LOG_FILE" ]]; then
            echo "Ejecutando comando con nohup y guardando salida en $LOG_FILE..."
            nohup bash -c "$COMMAND" > "$LOG_FILE" 2>&1 &
        else
            echo "Ejecutando comando con nohup y guardando salida en output.log..."
            nohup bash -c "$COMMAND" > output.log 2>&1 &
        fi
    else
        echo "Ejecutando comando con nohup y descartando salida..."
        nohup bash -c "$COMMAND" > /dev/null 2>&1 &
    fi
    
    PID=$!  # `$!`: PID del último proceso ejecutado
    echo "Comando ejecutado en segundo plano con PID $PID."
fi

# Caso 4: Si se proporciona --trace
if [[ -n "$TRACE" ]]; then
    if [[ -n "$LOG_FILE" ]]; then
        tail -f "$LOG_FILE"
    elif [[ "$LOG_OUTPUT" -eq 1 ]]; then
        tail -f output.log
    elif [[ -n "$TRACE" ]]; then
        if [[ "$TRACE" =~ ^[0-9]+$ ]]; then
            tail -f /proc/"$TRACE"/fd/1
        else
            echo "Error: Debes proporcionar un PID válido con --trace=PID."
            exit 1
        fi
    else
        echo "Error: Debes proporcionar un valor a --trace."
        usage
    fi
fi
