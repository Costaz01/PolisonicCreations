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
  size(400, 500);
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
     .setRange(0, 0.1)
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
     
     // Aggiungi questo codice all'interno della funzione setup() dopo l'inizializzazione di cp5

// Aggiungi questo codice all'interno della funzione setup() dopo l'inizializzazione di cp5

// Crea il menu a tendina per la selezione della forma d'onda
DropdownList d1 = cp5.addDropdownList("myList-d1")
                     .setPosition(50, 250)
                     .setSize(120, 100)
                     .setBackgroundColor(color(200))
                     .setItemHeight(20)
                     .setBarHeight(15);

d1.addItem("Seno", 1);
d1.addItem("Square", 2);
d1.addItem("Saw", 3);

d1.getCaptionLabel().set("Seleziona Onda");
d1.onChange(new CallbackListener() {
  public void controlEvent(CallbackEvent theEvent) {
    int selected = int(d1.getValue());
    sendOscMessage("/waveform", selected + 1);
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
// Questa funzione viene chiamata ogni volta che viene selezionato un elemento dal menu a tendina
void controlEvent(ControlEvent event) {
  if (event.isGroup()) {
    // Invia un messaggio OSC con il valore corrispondente alla selezione
    int value = int(event.getGroup().getValue());
    OscMessage myMessage = new OscMessage("/waveform");
    myMessage.add(value);
    oscP5.send(myMessage, myRemoteLocation);
  }
}
*/
