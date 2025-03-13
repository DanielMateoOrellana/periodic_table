#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Si no se proporciona argumento, muestra el mensaje y termina
if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit
fi

INPUT="$1"

# Si el argumento es un número, se busca por atomic_number
if [[ $INPUT =~ ^[0-9]+$ ]]; then
  QUERY="SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
         FROM elements e
         JOIN properties p ON e.atomic_number = p.atomic_number
         JOIN types t ON p.type_id = t.type_id
         WHERE e.atomic_number = $INPUT;"
else
  # Si es símbolo o nombre, se busca por igualdad exacta (sin comodines)
  QUERY="SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
         FROM elements e
         JOIN properties p ON e.atomic_number = p.atomic_number
         JOIN types t ON p.type_id = t.type_id
         WHERE e.symbol = '$INPUT'
            OR e.name ILIKE '$INPUT';"
fi

RESULT=$($PSQL "$QUERY")

if [ -z "$RESULT" ]; then
  echo "I could not find that element in the database."
else
  IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL MASS MELTING BOILING TYPE <<< "$RESULT"
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
fi

# refactor: improve script readability
# test: verify element.sh behavior with various inputs
