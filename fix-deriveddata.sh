#!/bin/bash

# Script para limpiar el DerivedData problemático

echo "🔧 Limpiando DerivedData de WNH..."

# Cerrar Xcode si está abierto
echo "⚠️  Por favor, CIERRA Xcode antes de continuar..."
read -p "Presiona Enter cuando hayas cerrado Xcode..."

# Eliminar el directorio problemático
rm -rf ~/Library/Developer/Xcode/DerivedData/WNH-hgfeqmnkfizwttanddkydouwzlcb

if [ $? -eq 0 ]; then
    echo "✅ DerivedData limpiado exitosamente!"
    echo "Ahora puedes abrir Xcode y compilar el proyecto."
else
    echo "❌ Error al eliminar. Intenta manualmente:"
    echo "rm -rf ~/Library/Developer/Xcode/DerivedData/WNH-hgfeqmnkfizwttanddkydouwzlcb"
fi

