import oscP5.*;
import netP5.*;
import controlP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
ControlP5 cp5;

boolean buttonState = false; // Stato del bottone: false è off, true è on
boolean detuneButtonState = false; // Stato del bottone detune: false è off, true è on
float knobValue = 20; // Valore iniziale del knob CutOff
float detuneKnobValue = 0; // Valore iniziale del knob Detune

void setup() {
  size(400, 300);
  oscP5 = new OscP5(this, 12000); // Inizializza oscP5 sulla porta 12000
  myRemoteLocation = new NetAddress("127.0.0.1", 57120); // Indirizzo e porta del destinatario OSC
  
  cp5 = new ControlP5(this);
  
  // Crea il bottone ON/OFF
  cp5.addButton("button")
     .setLabel("ON/OFF")
     .setPosition(50, 75)
     .setSize(100, 50)
     .onRelease(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         buttonState = !buttonState;
         sendOscMessage("/button", buttonState ? 1 : 0);
       }
     });
  
  // Crea il bottone Det. ON/OFF
  cp5.addButton("detuneButton")
     .setLabel("Det. ON/OFF")
     .setPosition(50, 150)
     .setSize(100, 50)
     .onRelease(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         detuneButtonState = !detuneButtonState;
         sendOscMessage("/detuneButton", detuneButtonState ? 1 : 0);
       }
     });
  
  // Crea il knob CutOff
  cp5.addKnob("cutOffKnob")
     .setLabel("CutOff")
     .setRange(20, 20000)
     .setValue(20)
     .setPosition(260, 50)
     .setRadius(20)
     .setNumberOfTickMarks(100)
     .setTickMarkLength(4)
     .snapToTickMarks(true)
     .setColorForeground(color(255, 100, 0))
     .setColorBackground(color(255, 255, 255))
     .setColorActive(color(0, 255, 0))
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent theEvent) {
         knobValue = theEvent.getValue();
         sendOscMessage("/cutOff", knobValue);
       }
     });
  
  // Crea il knob Detune
  cp5.addKnob("detuneKnob")
     .setLabel("Detune")
     .setRange(0, 0.10)
     .setValue(0)
     .setPosition(260, 150)
     .setRadius(20)
     .setNumberOfTickMarks(100)
     .setTickMarkLength(4)
     .snapToTickMarks(true)
     .setColorForeground(color(255, 100, 0))
     .setColorBackground(color(255, 255, 255))
     .setColorActive(color(0, 255, 0))
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent theEvent) {
         detuneKnobValue = theEvent.getValue();
         sendOscMessage("/detune", detuneKnobValue);
       }
     });
}

void draw() {
  background(255);
  fill(0);
  textAlign(CENTER, CENTER);
  text("ON/OFF", 100, 65);
  text("CutOff", 310, 45);
  text("Det. ON/OFF", 100, 140);
  text("Detune", 310, 145);
}

void sendOscMessage(String address, float value) {
  OscMessage myMessage = new OscMessage(address);
  myMessage.add(value);
  oscP5.send(myMessage, myRemoteLocation);
}

/*
import oscP5.*;
import netP5.*;
import controlP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
ControlP5 cp5;

boolean buttonState = false; // Stato del bottone: false è off, true è on
float knobValue = 20; // Valore iniziale del knob

void setup() {
  size(400, 200);
  oscP5 = new OscP5(this, 12000); // Inizializza oscP5 sulla porta 12000
  myRemoteLocation = new NetAddress("127.0.0.1", 57120); // Indirizzo e porta del destinatario OSC
  
  cp5 = new ControlP5(this);
  // Crea un knob
  cp5.addKnob("knob")
     .setRange(20, 20000) // Imposta il range del knob da 20 a 20000
     .setValue(20) // Imposta il valore iniziale del knob
     .setPosition(260, 50) // Imposta la posizione del knob
     .setRadius(50) // Imposta il raggio del knob
     .setNumberOfTickMarks(100) // Imposta il numero di tacche
     .setTickMarkLength(4) // Imposta la lunghezza delle tacche
     .snapToTickMarks(true) // Fa sì che il knob si agganci alle tacche
     .setColorForeground(color(255, 100, 0)) // Imposta il colore di primo piano
     .setColorBackground(color(255, 255, 255)) // Imposta il colore di sfondo
     .setColorActive(color(0, 255, 0)); // Imposta il colore attivo
}

void draw() {
  background(255);
  // Disegna il bottone
  if (buttonState) {
    fill(0, 255, 0); // Colore verde se il bottone è on
  } else {
    fill(255, 0, 0); // Colore rosso se il bottone è off
  }
  rect(50, 75, 100, 50); // Disegna il bottone
}

void mousePressed() {
  int buttonX = 50, buttonY = 75, buttonWidth = 100, buttonHeight = 50;
  // Controlla se il mouse è all'interno del bottone
  if (mouseX > buttonX && mouseX < buttonX + buttonWidth && mouseY > buttonY && mouseY < buttonY + buttonHeight) {
    buttonState = !buttonState; // Cambia lo stato del bottone
    sendOscMessage("/button", buttonState ? 1 : 0); // Invia il messaggio OSC
  }
}

void knob(float theValue) {
  knobValue = theValue;
  sendOscMessage("/knob", theValue); // Invia il valore del knob via OSC
}

void sendOscMessage(String address, float value) {
  OscMessage myMessage = new OscMessage(address);
  myMessage.add(value);
  oscP5.send(myMessage, myRemoteLocation);
}
*/
