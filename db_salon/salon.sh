#!/bin/bash

PSQL="psql --username=freecodecamp --dbnam=salon --tuples-only -c"

echo -e "\n~~~ MY SALON ~~~"

MAIN_MENU() {
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  SHOW_SERVICES
}

SHOW_SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1";
  else
    echo -e "\nWelcome to My Salon, how can i help you?\n"
  fi
  echo "$SERVICE_LIST" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    SERVICE_ID=$(echo $SERVICE_ID | sed -E 's/^ *| *$//')
    SERVICE_NAME=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//')
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  # check if service_id_selected is a number.
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SHOW_SERVICES "I could not find that service. What would you like today?"
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    SHOW_SERVICES "I could not find that service. What would you like today?"
  else
    MAKE_APPOINTMENT $SERVICE_ID_SELECTED "$SERVICE_NAME"
  fi
}

MAKE_APPOINTMENT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_INFO=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_INFO ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  else
    read CUSTOMER_ID BAR CUSTOMER_NAME <<< "$CUSTOMER_INFO"
  fi
  SERVICE_NAME_FORMATED=$(echo $2 | sed -E 's/^ *| *$//')
  echo -e "what time would you like your $SERVICE_NAME_FORMATED, $CUSTOMER_NAME"
  read SERVICE_TIME
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")
  echo -e "I have put you down for a $SERVICE_NAME_FORMATED at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU