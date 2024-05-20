import oscP5.*;
import netP5.*;
import controlP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
ControlP5 cp5;


boolean chorusButtonState = false; // Stato del bottone Chorus: false è off, true è on
boolean distortionButtonState = false;
boolean buttonState = false; // Stato del bottone: false è off, true è on
boolean detuneButtonState = false; // Stato del bottone detune: false è off, true è on
float knobValue = 20; // Valore iniziale del knob CutOff
float detuneKnobValue = 0; // Valore iniziale del knob Detune
float panKnobValue = 0; // Valore iniziale del knob Pan
PImage bg;

void setup() {
  size(700, 500);
  bg = loadImage("Background(4).png");
  oscP5 = new OscP5(this, 12000); // Inizializza oscP5 sulla porta 12000
  myRemoteLocation = new NetAddress("127.0.0.1", 57120); // Indirizzo e porta del destinatario OSC

  cp5 = new ControlP5(this);

   cp5.addKnob("attackKnob")
     .setLabel("Attack")
     .setRange(0.01, 0.99)
     .setValue(0.01)
     .setPosition(250, 75) // Adjust position as needed
     .setRadius(20)
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent theEvent) {
         sendOscMessage("/attack", theEvent.getValue());
       }
     });

  // Add the Decay knob
  cp5.addKnob("decayKnob")
     .setLabel("Decay")
     .setRange(0, 10)
     .setValue(0)
     .setPosition(350, 75) // Adjust position as needed
     .setRadius(20)
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent theEvent) {
         sendOscMessage("/decay", theEvent.getValue());
       }
     });

  // Add the Sustain knob
  cp5.addKnob("sustainKnob")
     .setLabel("Sustain")
     .setRange(0, 1)
     .setValue(1)
     .setPosition(450, 75) // Adjust position as needed
     .setRadius(20)
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent theEvent) {
         sendOscMessage("/sustain", theEvent.getValue());
       }
     });

  // Add the Release knob
  cp5.addKnob("releaseKnob")
     .setLabel("Release")
     .setRange(0, 0.999)
     .setValue(0)
     .setPosition(550, 75) // Adjust position as needed
     .setRadius(20)
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent theEvent) {
         sendOscMessage("/release", theEvent.getValue());
       }
     });
     
     // Add the Amplitude knob
  cp5.addKnob("ampKnob")
     .setLabel("Amp")
     .setRange(0, 1)
     .setValue(1)
     .setPosition(75, 30) // Adjust position as needed
     .setRadius(15)
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent theEvent) {
         sendOscMessage("/amp", theEvent.getValue());
       }
     });


  
  // Filter On/Off button
  cp5.addButton("button")
     .setLabel("ON/OFF")
     .setPosition(50, 175)
     .setSize(100, 50)
     .onRelease(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         buttonState = !buttonState;
         sendOscMessage("/button", buttonState ? 1 : 0);
         cp5.getController("button").setColorBackground(buttonState ? color(0, 255, 0) : color(240, 240, 240));
       }
     });
  
  // Detune On/Off button
  cp5.addButton("detuneButton")
     .setLabel("Det. ON/OFF")
     .setPosition(50, 250)
     .setSize(100, 50)
     .onRelease(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         detuneButtonState = !detuneButtonState;
         sendOscMessage("/detuneButton", detuneButtonState ? 1 : 0);
         cp5.getController("detuneButton").setColorBackground(detuneButtonState ? color(0, 255, 0) : color(240, 240, 240));
       }
     });
     
  // Distortion On/Off button    
   cp5.addButton("distortionButton")
   .setLabel("Distortion")
   .setPosition(50, 400) // Adjust the position as needed
   .setSize(100, 50)
   .onRelease(new CallbackListener() {
     public void controlEvent(CallbackEvent theEvent) {
       distortionButtonState = !distortionButtonState;
       sendOscMessage("/distortion", distortionButtonState ? 1 : 0);
       cp5.getController("distortionButton").setColorBackground(distortionButtonState ? color(0, 255, 0) : color(240, 240, 240));
     }
   });
  
  
  // Chorus On/Off button
  cp5.addButton("chorusButton")
     .setLabel("Chorus")
     .setPosition(50, 325)
     .setSize(100, 50)
     .onRelease(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         chorusButtonState = !chorusButtonState;
         sendOscMessage("/chorus", chorusButtonState ? 1 : 0);
         cp5.getController("chorusButton").setColorBackground(chorusButtonState ? color(0, 255, 0) : color(240, 240, 240));
       }
     });
  
  // Crea il knob CutOff
  cp5.addKnob("cutOffKnob")
     .setLabel("CutOff")
     .setRange(20, 20000)
     .setValue(20)
     .setPosition(260, 175)
     .setRadius(20)
     
     
 
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
     .setPosition(260, 250)
     .setRadius(20)
     
     
     
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent theEvent) {
         detuneKnobValue = theEvent.getValue();
         sendOscMessage("/detune", detuneKnobValue);
       }
     });
  
  cp5.addKnob("panKnob")
     .setLabel("Pan")
     .setRange(-1, 1)
     .setValue(0)
     .setPosition(125, 30)
     .setRadius(15)
     
     
     
     .addListener(new ControlListener() {
       public void controlEvent(ControlEvent theEvent) {
         panKnobValue = theEvent.getValue();
         sendOscMessage("/pan", panKnobValue);
       }
     });
  
  // Crea il menu a tendina per la selezione della forma d'onda
  DropdownList d1 = cp5.addDropdownList("myList-d1")
                       .setPosition(50, 75)
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
  background(bg);
  fill(0);
  textAlign(CENTER, CENTER);
  ;
  text("CutOff", 280, 228);
  text("Pan", 140, 20);
  text("Detune", 280, 303);
  text("Chorus", 100, 215);
  text("Attack", 280, 50);
  text("Decay", 380, 50);
  text("Sustain", 480, 50);
  text("Release", 580, 50);
  text("Volume", 90, 20);// Aggiunto il testo per il bottone Chorus
}

void sendOscMessage(String address, float value) {
  OscMessage myMessage = new OscMessage(address);
  myMessage.add(value);
  oscP5.send(myMessage, myRemoteLocation);
}
