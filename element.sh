#! /bin/bash

# Define la variable para ejecutar consultas en la base de datos periodic_table
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Si no se proporciona ningún argumento, muestra el mensaje y termina
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

# Verifica si el argumento es numérico (atomic number) o texto (símbolo o nombre)
if [[ $1 =~ ^[0-9]+$ ]]
then
  QUERY="SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
         FROM elements e 
         JOIN properties p USING(atomic_number) 
         JOIN types t USING(type_id) 
         WHERE e.atomic_number = $1"
else
  QUERY="SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
         FROM elements e 
         JOIN properties p USING(atomic_number) 
         JOIN types t USING(type_id) 
         WHERE e.symbol ILIKE '$1' OR e.name ILIKE '$1'"
fi

RESULT=$($PSQL "$QUERY")

# Si no se encontró ningún elemento, muestra mensaje y termina
if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

# Separa el resultado en variables (asumiendo que los campos están separados por "|" )
IFS="|" read ATOMIC_NUMBER SYMBOL NAME TYPE MASS MELTING BOILING <<< "$RESULT"

# Imprime la información en el formato requerido
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
