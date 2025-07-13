#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU (){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\n~~~ SALON MENU ~~~\n"

  echo "Select a service:"
  GET_SERVICES=$($PSQL "select * from services")
  echo -e "$GET_SERVICES" | while IFS=' ' read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in 
    [1-3]) GET_CUSTOMER ;;
    *) MAIN_MENU "Could not find that service. Pick a number shown pls."
  esac
}

GET_CUSTOMER () {
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

  # if customer not found
  if [[ -z $CUSTOMER_ID ]]
  then
  #create customer
  echo -e "\nPlease enter your name:"
  read CUSTOMER_NAME

  INSERT_CUSTOMER=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  fi

  #customer is found
  echo -e "\nPlease enter a time for your appointment:"
  read SERVICE_TIME

  CREATE_APPT=$($PSQL "insert into appointments(customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  if [[ $CREATE_APPT == 'INSERT 0 1' ]]
  then
    CUSTOMER_NAME=$($PSQL "select name from customers where customer_id = $CUSTOMER_ID")
    SERVICE_SELECTED=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")

    echo $CUSTOMER_NAME
    echo $SERVICE_SELECTED

    echo -e "\nI have put you down for a$SERVICE_SELECTED at $SERVICE_TIME,$CUSTOMER_NAME."
  fi

}

MAIN_MENU
