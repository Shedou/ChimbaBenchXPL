#!/bin/bash

# 1. Проверка WINE (нативное выполнение никогда не должно выводить WINE)
echo "REAL"

# 2. OS
if [ -f /etc/os-release ]; then
    grep "PRETTY_NAME" /etc/os-release | cut -d '"' -f 2
else
    uname -sr
fi

# 3. CPU
grep "model name" /proc/cpuinfo | head -n 1 | cut -d ':' -f 2 | sed 's/^[ \t]*//'

# 4. VGA
lspci | grep -iE 'vga|3d' | cut -d ':' -f 3 | sed 's/^[ \t]*//' | head -n 1
