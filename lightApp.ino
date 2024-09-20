#include <SoftwareSerial.h>

// Define TX and RX pins for the Bluetooth module
SoftwareSerial bluetooth(9, 3);//Actual pins on circuit

// Define pin for controlling the light
const int lightPin = 7; // Actual pin on circuit

void setup() {
  // Initialize serial communication at 9600 bps
  bluetooth.begin(9600);
  Serial.begin(9600);

  // Set the light pin as an output
  pinMode(lightPin, OUTPUT);
}

void loop() {
  if (bluetooth.available()) { 
    char receivedChar = bluetooth.read();
    Serial.print("Received: ");
    Serial.println(receivedChar, HEX);

    // Check if received character is '0' or '1' and control the light accordingly
    if (receivedChar == 0) {
      digitalWrite(lightPin, LOW); // Turn off the light
    } 
    
    else if (receivedChar == 1) {
      digitalWrite(lightPin, HIGH); // Turn on the light
    }
  }
}
