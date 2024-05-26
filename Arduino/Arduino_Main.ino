#define LED_PIN 9
#define BUTTON_PIN 7
#define LED_2_PIN 8
#define BUTTON_2_PIN 6
#define LED_3_PIN 10
#define BUTTON_3_PIN 5
#define LED_R_PIN 11
#define BUTTON_R_PIN 4
#define POTENTIOMETER_PIN A0
#define POTENTIOMETER_2_PIN A1
#define SENSOR_PIN A2

byte lastButtonState = LOW;
byte ledState = LOW;
byte lastButtonState2 = LOW;
byte ledState2 = LOW;
byte lastButtonState3 = LOW;
byte ledState3 = LOW;
byte lastButtonStateR = LOW;
byte ledStateR = LOW;

int AmplitudeArray[400];
int i = 0;
int j = 0;



unsigned long debounceDuration = 50; // millis
unsigned long lastTimeButtonStateChanged = 0;

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT);
  pinMode(LED_2_PIN, OUTPUT);
  pinMode(BUTTON_2_PIN, INPUT);
  pinMode(LED_3_PIN, OUTPUT);
  pinMode(BUTTON_3_PIN, INPUT);
  pinMode(LED_R_PIN, OUTPUT);
  pinMode(BUTTON_R_PIN, INPUT);

  for (int z = 0;z<400;z++) {
  AmplitudeArray[z] = -1;
  };
}
void loop() {

  int sensorValue1 = analogRead(A0);
  int val = (round(sensorValue1/8.055));
  int sensorValue2 = analogRead(A1);
  int val2 = (round(sensorValue2/8.055));
  int sensorValue3 = analogRead(A2);
  int val3 = (round(sensorValue3/8.055));


   if (millis() - lastTimeButtonStateChanged > debounceDuration) {
  byte buttonState  = digitalRead(BUTTON_PIN);
  byte buttonState2 = digitalRead(BUTTON_2_PIN);
  byte buttonState3 = digitalRead(BUTTON_3_PIN);
  byte buttonStateR = digitalRead(BUTTON_R_PIN);


  if (buttonState != lastButtonState) {
    lastTimeButtonStateChanged = millis();
    lastButtonState = buttonState;
    if (buttonState == LOW) {
      ledState = (ledState == HIGH) ? LOW: HIGH;
      digitalWrite(LED_PIN, ledState);
    }
  }
  if (buttonState2 != lastButtonState2) {
    lastTimeButtonStateChanged = millis();
    lastButtonState2 = buttonState2;
    if (buttonState2 == LOW) {
      ledState2 = (ledState2 == HIGH) ? LOW: HIGH;
      digitalWrite(LED_2_PIN, ledState2);
    }
  }

  if (buttonState3 != lastButtonState3) {
  lastTimeButtonStateChanged = millis();
  lastButtonState3 = buttonState3; 
    if (buttonState3 == LOW) {
      ledState3 = (ledState3 == HIGH) ? LOW: HIGH;
      digitalWrite(LED_3_PIN, ledState3);
        if (ledState3 == HIGH) {
        for (int z = 0;z<400;z++) {
        AmplitudeArray[z] = -1;
        i = 0;
        };
      } 
    }
  }

    if(buttonStateR == HIGH){
      for (int z = 0;z<400;z++) {
      AmplitudeArray[z] = -1;
      digitalWrite(LED_R_PIN, HIGH);
    }}
    else{
      digitalWrite(LED_R_PIN, LOW);      
    }
}
/*
  if (ledState == HIGH){
            Serial.print(1);
            Serial.print('a');
            Serial.print(val);
            Serial.print('b');
            
  }
  else{
            Serial.print(0);
            Serial.print('a');
            Serial.print(127);
            Serial.print('b');
  };*/
  /*if (ledState2 == HIGH){
            Serial.print(val2);
            Serial.print('b');
            
  }
  else{
            Serial.print(127);
            Serial.print('b');
  };
*/


  if (ledState3 == HIGH){
    AmplitudeArray[i] = val3;
    Serial.print(AmplitudeArray[i]);
    Serial.print('c'); // Microphone value
    Serial.print('1'); // Record button on
    Serial.print('d'); // Record button variable
    Serial.print('0'); // Loop off
    Serial.print('e'); // Loop variable
    i = i + 1;                       
      if (i == 400) { // 20 seconds recording
      i = 0;
      }}
  else{   
      if (AmplitudeArray[0] == -1){
        Serial.print(127);
        Serial.print('c');
        Serial.print('0');
        Serial.print('d');
        Serial.print('0'); // Loop off
        Serial.print('e'); // Loop variable
      }
      else{
        if (AmplitudeArray[j] != -1) {
          Serial.print(AmplitudeArray[j]);
          Serial.print('c');  
          Serial.print('0');
          Serial.print('d');
          Serial.print('1'); // Loop off
          Serial.print('e'); // Loop variable
          j = j + 1;   
        }
        else {
          j = 0;
          Serial.print(AmplitudeArray[j]);
          Serial.print('c'); 
          Serial.print('0');
          Serial.print('d');  
          Serial.print('1'); // Loop off
          Serial.print('e'); // Loop variable     
        }
      }
  }
    delay(50);
  }