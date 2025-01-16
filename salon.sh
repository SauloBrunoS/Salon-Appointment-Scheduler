#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

# Function to display available services
DISPLAY_SERVICES() {
    echo -e "\n~~~~~ MY SALON ~~~~~\n"
    echo -e "Welcome to My Salon, how can I help you?\n"

    # List all services
    AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services;")
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID SERVICE_NAME
    do
      echo "$SERVICE_ID $SERVICE_NAME" | sed 's/|/) /'
    done
    
    # Ask user for a service
    read SERVICE_ID_SELECTED
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_NAME ]]
    then
      echo "I could not find that service. What would you like today?"
      DISPLAY_SERVICES
    fi
}

# Function to add appointments
ADD_APPOINTMENT() {
    # Ask for phone number
    echo "What's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    if [ -z $CUSTOMER_ID ]
    then
      # Customer does not exist, ask for name
      echo "I don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
    fi
    # Ask for the time of the appointment
    echo "What time would you like your service at, $CUSTOMER_NAME?"
    read SERVICE_TIME
    # Insert the appointment into the database
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

DISPLAY_SERVICES
ADD_APPOINTMENT

