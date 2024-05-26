import oscP5.*;
import netP5.*;
import controlP5.*;
import processing.serial.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
ControlP5 cp5;
//Serial myPort;

Button filterButton, detuneButton, chorusButton, distortButton, recordButton; 
Knob detuneKnob, volumeKnob, panKnob; //Basic control knobs
Knob cutOffKnob, resonanceKnob, filterAttackKnob, filterDecayKnob, filterSustainKnob, filterReleaseKnob; //Filter Knobs
Knob attackKnob, decayKnob, sustainKnob, releaseKnob; //ADSR knobs
Knob chorusMixKnob, chorusDepthKnob, chorusDelayKnob, chorusFeedbackKnob; // Chorus knobs
Knob distortionMixKnob, distortionFilterKnob; // Distortion knobs
DropdownList d1, d2;

String charArray = ""; // to read Arduino serial code
boolean chorusButtonState = false; // Chorus button state: false=off, true=on
boolean distortionButtonState = false; // Distortion button state: false=off, true=on
boolean cutoffButtonState = false; // Filter button state: false=off, true=on
boolean detuneButtonState = false; // Detune button state: false=off, true=on
boolean recordButtonState = false; // Record button state: false=off, true=on
boolean loopButtonState = false; // Loop button state: false=off, true=on
int cutOff = 200; // Initial cutoff value
float detune = 0; // Valore iniziale del knob Detune
float panKnobValue = 0; // Valore iniziale del knob Pan
int attack = 0, decay = 0, sustain = 0, release = 0;
float amp = 1.0, pan = 0.0, waveform, voiceSelect, volume = 1.0;
float chorusMix = 1, chorusDepth = 0, chorusDelay = 0, chorusFeedback = 0; // Chorus global variables
float distortionMix = 1, distortionFilter = 0; // Distortion global variables
float resonance = 0;
int filterAttack = 0, filterDecay = 0, filterSustain = 0, filterRelease = 0; 
PImage img, img2, img3, img4, img5, img6, img7, img8, img9, img10, img11, img12, img13, img14, img15, img16; 
PFont myFont;


void setup() {
  size(700, 500);
  myFont = createFont("YuppyTC-Regular", 12);
String[] fontList = PFont.list();
printArray(fontList);
  img = loadImage("3biscot.png");
  img2 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/3biscot(evil).png");
  img3 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/6biscot.png");
  img4 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/6biscot(evil).png");
  img5 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/3bisblurred.png");
  img6 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/3bisblurred(evil).png");
  img7 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/3biscuba.png");
  img8 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/3biscuba(evil).png");
  img9 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/3biscublurred.png");
  img10 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/3biscublurred(evil).png");
  img11 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/6bisblurred.png");
  img12 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/6bisblurred(evil).png");
  img13 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/6biscuba.png");
  img14 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/6biscuba(evil).png");
  img15 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/6biscublurred.png");
  img16 = loadImage("/Users/costa/Desktop/CMLS Final/GUI/6biscublurred(evil).png");
  background(img);
  
  oscP5 = new OscP5(this, 12000); // Initialize oscP5 on port 12000
  myRemoteLocation = new NetAddress("127.0.0.1", 57120); // Indirizzo e porta del destinatario OSC
  
  // Arduino
  //String portName = Serial.list()[2]; // Sostituisci con il numero di porta corretto
  //myPort = new Serial(this, portName, 115200);
  
  cp5 = new ControlP5(this);  // Inizializzazione del ControlP5

//=======================  BUTTONS ===========================//

  // Cutoff
 filterButton = cp5.addButton("cutoffState")
     .setLabel("Filter")
     .setPosition(170, 175)
     .setSize(20, 20)
     .setColorBackground(color(20, 49, 9))
     .setColorForeground(color(111,138,183));

     

  // Detune
 detuneButton = cp5.addButton("detuneState")
     .setLabel("Detune")
     .setPosition(290, 175)
     .setSize(20, 20)
     .setColorBackground(color(20, 49, 9))
     .setColorForeground(color(111,138,183));


  // Chorus
  chorusButton = cp5.addButton("chorusState")
     .setLabel("Chorus")
     .setPosition(410, 175)
     .setSize(20, 20)
     .setColorBackground(color(20, 49, 9))
     .setColorForeground(color(111,138,183));

     
  // Distortion  
  distortButton = cp5.addButton("distortionState")
   .setLabel("Distortion")
   .setPosition(530, 175) // Adjust the position as needed
   .setSize(20, 20)
   .setColorBackground(color(20, 49, 9))
   .setColorForeground(color(111,138,183));

   
  // Record  
  recordButton = cp5.addButton("recordButtonState")
   .setLabel("Record")
   .setPosition(75, 400) // Adjust the position as needed
   .setSize(100, 50)
   .setColorBackground(color(76,1,20))
   .setColorForeground(color(111,138,183));

   
   
   
// ======================= KNOBS ============================//

  // Add the Chorus Mix
  chorusMixKnob = cp5.addKnob("chorusMix")
     .setLabel("Mix")
     .setRange(0.0, 1)
     .setValue(1)
     .setPosition(400, 225) 
     .setRadius(20)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));
     
     
  // Add the Chorus Depth
  chorusDepthKnob = cp5.addKnob("chorusDepth")
     .setLabel("Depth")
     .setRange(0.0, 1)
     .setValue(0)
     .setPosition(365, 280)
     .setRadius(20)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));

  // Add the Chorus Rate
  chorusDelayKnob = cp5.addKnob("chorusDelay")
     .setLabel("Delay")
     .setRange(0.0, 1)
     .setValue(0)
     .setPosition(435, 280) 
     .setRadius(20)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));
     
  // Add the Chorus Feedback
  chorusFeedbackKnob = cp5.addKnob("chorusFeedback")
     .setLabel("FeedBack")
     .setRange(0, 1)
     .setValue(0.5)
     .setPosition(400, 330)
     .setRadius(20)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));    
     
  // Add the Distortion Mix
  distortionMixKnob = cp5.addKnob("distortionMix")
     .setLabel("Mix")
     .setRange(0.0, 1)
     .setValue(1)
     .setPosition(520, 225)
     .setRadius(20)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));
     
  // Add the Distortion Filter
  distortionFilterKnob = cp5.addKnob("distortionFilter")
     .setLabel("Filter")
     .setRange(0.0, 1)
     .setValue(1)
     .setPosition(520, 280) 
     .setRadius(20)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));  
     
// ======================= ADSR Envelope Knobs ============================//  

  // Add the Attack Knob  
  attackKnob = cp5.addKnob("attack")
     .setLabel("Attack")
     .setRange(1, 100)
     .setValue(0.01)
     .setPosition(65, 70)
     .setRadius(15)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));

  // Add the Decay knob
  decayKnob = cp5.addKnob("decay")
     .setLabel("Decay")
     .setRange(0, 100)
     .setValue(0)
     .setPosition(110, 70) 
     .setRadius(15)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));

  // Add the Sustain knob
  sustainKnob = cp5.addKnob("sustain")
     .setLabel("Sustain")
     .setRange(0, 100)
     .setValue(100)
     .setPosition(155, 70)
     .setRadius(15)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));
     
  // Add the Release knob
  releaseKnob = cp5.addKnob("release")
     .setLabel("Release")
     .setRange(0, 100)
     .setValue(0)
     .setPosition(200, 70) 
     .setRadius(15)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));

// ======================= Filter Knobs ============================// 
     

  cutOffKnob = cp5.addKnob("cutOff")
     .setLabel("CutOff")
     .setRange(0, 200)
     .setValue(200)
     .setPosition(160, 225)
     .setRadius(20)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));

  // Add the Resonance knob
  resonanceKnob = cp5.addKnob("resonance")
    .setLabel("Resonance")
     .setRange(0, 1)
     .setValue(1)
     .setPosition(160, 280)
     .setRadius(20)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));
     
     
  // Add the Filter Attack Knob  
  filterAttackKnob = cp5.addKnob("filterAttack")
     .setLabel("Attack")
     .setRange(1, 100)
     .setValue(1)
     .setPosition(90, 225)
     .setRadius(15)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));

  // Add the Filter Decay knob
  filterDecayKnob = cp5.addKnob("filterDecay")
     .setLabel("Decay")
     .setRange(0, 100)
     .setValue(0)
     .setPosition(90, 275) 
     .setRadius(15)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));

  // Add the Filter Sustain knob
  filterSustainKnob = cp5.addKnob("filterSustain")
     .setLabel("Sustain")
     .setRange(0, 100)
     .setValue(100)
     .setPosition(90, 325)
     .setRadius(15)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));
    
     
     
// ======================= Basic Control Knobs ============================//   
     
  // Add the Volume knob
  volumeKnob = cp5.addKnob("volume")
     .setLabel("Volume")
     .setRange(0, 1)
     .setValue(1)
     .setPosition(520, 30) 
     .setRadius(20)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));
  
  // Add the Detune knob
  detuneKnob = cp5.addKnob("detune")
    .setLabel("Amount")
     .setRange(0, 0.1)
     .setValue(0)
     .setPosition(280, 225)
     .setRadius(20)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));
     
  // Add the Pan knob
  panKnob = cp5.addKnob("pan")
     .setLabel("Pan")
     .setRange(-1, 1)
     .setValue(0)
     .setPosition(600, 30)
     .setRadius(20)
     .setDragDirection(1)
     .setColorBackground(color(105, 89, 88))
     .setColorForeground(color(219,216,174))
     .setColorActive(color(234,244,211));

     
     
// ======================= DROPDOWN  MENU ======================== //

  // Dropdown menu for the oscillator's waveform
  d1 = cp5.addDropdownList("waveform")
                       .setPosition(50, 40)
                       .setSize(200, 120)
                       .setColorBackground(color(91,60,45))
                       .setColorForeground(color(219,216,174))
                       .setColorActive(color(234,244,211))                    
                       .setItemHeight(20)
                       .setBarHeight(15);
  
  d1.addItem("Sin", 1);
  d1.addItem("Square", 2);
  d1.addItem("Saw", 3);
  d1.getCaptionLabel().set("Select waveform");
  
  // Dropdown menu for the parameter assignment
  d2 = cp5.addDropdownList("voiceSelect")
                       .setPosition(200, 400)
                       .setSize(100, 120)
                       .setColorBackground(color(91,60,45))
                       .setColorForeground(color(219,216,174))
                       .setColorActive(color(234,244,211))
                       .setItemHeight(20)
                       .setBarHeight(15);

  d2.addItem("Cutoff", 1);
  d2.addItem("Amp", 2);
  d2.getCaptionLabel().set("Select Control");
  
  
}

void draw() {
  background(img);
  fill(234,244,211);
  textAlign(CENTER, CENTER);

  
  if (distortionButtonState){ 
  background(img2);
    }
    else if(chorusButtonState){
  background(img3);
    }
  
  if (chorusButtonState && distortionButtonState) {
  background(img4);  
    }

  if (detuneButtonState) {
  background(img5);  
  }
  
  if (distortionButtonState && detuneButtonState) {
  background(img6);  
    }
    
  if (cutoffButtonState) {
  background(img7);  
    }
    
  if (cutoffButtonState && distortionButtonState) {
  background(img8);  
    }
    
  if (cutoffButtonState && detuneButtonState) {
  background(img9);  
    }
    
  if (cutoffButtonState && detuneButtonState && distortionButtonState) {
  background(img10);  
    } 
    
  if (chorusButtonState && detuneButtonState) {
  background(img11);  
    }
    
  if (chorusButtonState && detuneButtonState && distortionButtonState) {
  background(img12);  
    }
    
  if (chorusButtonState && cutoffButtonState) {
  background(img13);  
    }
    
  if (chorusButtonState && cutoffButtonState && distortionButtonState) {
  background(img14);  
    }
   
  if (chorusButtonState && cutoffButtonState && detuneButtonState) {
  background(img15);  
    }
      
  if (chorusButtonState && cutoffButtonState && detuneButtonState && distortionButtonState) {
  background(img16);  
    }
  
    
  textFont(myFont);
  text(" FILTER\n ENVELOPE", 105, 190);
/*
   while (myPort.available() > 0) {
      boolean bool = false;
      char receivedChar = myPort.readChar(); // Read a single character
      if (Character.isDigit(receivedChar)) {
        charArray += receivedChar; // Append digit characters to the string
      } else if (receivedChar == 'b') {
        float val = Integer.parseInt(charArray);
        cutOff = round(map(val, 0, 127, 0, 200));
        charArray = ""; 
      } else if (receivedChar == 'a') {
        bool = (Integer.parseInt(charArray) == 1);
        if(bool != cutoffButtonState){
          cutoffButtonState = !cutoffButtonState;
        }
        charArray = ""; // Clear the string        
      }
      else if (receivedChar == 'c') {
        bool = (Integer.parseInt(charArray) == 1);
        if(bool != detuneButtonState){
          detuneButtonState = !detuneButtonState;
        }
        charArray = ""; // Clear the string        
        }
        else if (receivedChar == 'd') {
        detune = map(Integer.parseInt(charArray), 0, 127, 0, 0.1);
        charArray = ""; 
        }
        else if (receivedChar == 'e') {
        bool = (Integer.parseInt(charArray) == 1);
        println(bool);
        if(bool != chorusButtonState){
          chorusButtonState = !chorusButtonState;
        }
        charArray = ""; // Clear the string        
        }
        else if (receivedChar == 'f') {
        chorusMix = map(Integer.parseInt(charArray), 0, 127, 0, 1);
        charArray = ""; 
        }
        else if (receivedChar == 'g') {
        bool = (Integer.parseInt(charArray) == 1);
        println(bool);
        if(bool != distortionButtonState){
          distortionButtonState = !distortionButtonState;
        }
        charArray = ""; // Clear the string        
        }
        else if (receivedChar == 'h') {
        distortionMix = map(Integer.parseInt(charArray), 0, 127, 0, 1);
        charArray = ""; 
        }
        else if (receivedChar == 'i') {
          bool = (Integer.parseInt(charArray) == 1);
          if(bool != recordButtonState){
            recordButtonState = !recordButtonState;
          }     
          charArray = "";
        }
        else if (receivedChar == 'j') {
          bool = (Integer.parseInt(charArray) == 1);
          if(bool != loopButtonState){
            loopButtonState = !loopButtonState;
          }     
          charArray = "";
        }
        else if (receivedChar == 'k') {
          amp = Integer.parseInt(charArray);
          //amp = logScale((int)Integer.parseInt(charArray), 127, 0.0, 127.0);
          //println(amp);       
          charArray = ""; 
        }          
  }

  // Record update
  if(recordButtonState){
     recordButton.setValue(1);
     recordButton.setLabel("Record");
     recordButtonState = !recordButtonState;
     recordButton.setColorBackground(color(194, 1, 20));
     if (d2.getValue() == 1){
     amp = map(amp, 0, 127, 0.3, 0.8);
     //volumeKnob.setValue(amp);
     sendOscMessage("/amp", amp);
       } 
       else if (d2.getValue() ==0){
        amp = map(amp, 0, 127, 70, 200);
        cutOffKnob.setValue(amp);
        sendOscMessage("/cutOff", amp);
       } 
       else {
       
       }
     }  
   else if(loopButtonState){
     recordButton.setLabel("Loop");
     loopButtonState = !loopButtonState;
     recordButton.setColorBackground(color(150, 1, 200));
     if (d2.getValue() == 1){
       amp = map(amp, 0, 127, 0.3, 0.8);
       sendOscMessage("/amp", amp);
       } 
     else if (d2.getValue() == 0){
        amp = map(amp, 0, 127, 70, 200);
        cutOffKnob.setValue(amp);
        sendOscMessage("/cutOff", amp);
       } 
       else {
       
       }
   }
   else if(!loopButtonState && !recordButtonState){
     recordButton.setValue(0);
     recordButton.setLabel("Record");
     loopButtonState = !loopButtonState;
     recordButton.setColorBackground(color(76,1,20));
   };
   
  // Filter update
  if(cutoffButtonState){
     filterButton.setValue(1);
     cutoffButtonState = !cutoffButtonState;
     filterButton.setColorBackground(color(40, 150, 90));
     sendOscMessage("/cutoffState", 1);
     if(d2.getValue() != 0){
       cutOffKnob.setValue(cutOff);
       sendOscMessage("/cutOff", cutOff);
     }
     }
  
   else{
     filterButton.setValue(0);
     cutoffButtonState = !cutoffButtonState;
     filterButton.setColorBackground(color(20, 49, 9));
     sendOscMessage("/cutoffState", 0);
   };
   
   // Detune update
   if(detuneButtonState){
     detuneButton.setValue(1);
     detuneButtonState = !detuneButtonState;
     detuneButton.setColorBackground(color(40, 150, 90));
     sendOscMessage("/detuneState", 1);
     detuneKnob.setValue(detune);
     sendOscMessage("/detune", detune);
     }
  
   else{
     detuneButton.setValue(0);
     detuneButtonState = !detuneButtonState;
     detuneButton.setColorBackground(color(20, 49, 9));
     sendOscMessage("/detuneState", 0);
   };
   
   // Chorus update
   if(!chorusButtonState){
     chorusButton.setValue(1);
     chorusButtonState = !chorusButtonState;
     chorusButton.setColorBackground(color(20, 49, 9));
     sendOscMessage("/chorusState", 1);
     }
  
   else{
     chorusButton.setValue(0);
     chorusButtonState = !chorusButtonState;
     chorusButton.setColorBackground(color(40, 150, 90));
     sendOscMessage("/chorusState", 0);
     chorusMixKnob.setValue(chorusMix);
     sendOscMessage("/chorusMix", chorusMix);
   };
   
   // Distortion update
   if(!distortionButtonState){
     distortButton.setValue(1);
     distortionButtonState = !distortionButtonState;
     distortButton.setColorBackground(color(20, 49, 9));
     sendOscMessage("/distortionState", 1);
     }
  
   else{
     distortButton.setValue(0);
     distortionButtonState = !distortionButtonState;
     distortButton.setColorBackground(color(40, 150, 90));
     distortionMixKnob.setValue(distortionMix);
     sendOscMessage("/distortionMix", distortionMix);
     sendOscMessage("/distortionState", 0);
   };
delay(70);*/
}


void controlEvent (ControlEvent theEvent){
  String which_control = theEvent.getName().toString(); // è arrivato un ControlEvent: da quale Controller è stato generato? 
  String address = null; 
  float value = 0.0;
  switch (which_control) {        // Ora che sappiamo da chi è stato generato, possiamo distinguere i vari casi
          
// ------------------- Pulsanti ------------------//
    case "cutoffState": 
       address = which_control;
       cutoffButtonState = !cutoffButtonState;
       value = cutoffButtonState ? 1 : 0;
       cp5.getController("cutoffState").setColorBackground(cutoffButtonState ? color(40, 150, 90) : color(20, 49, 9));
    break;

    case "detuneState":
       address = which_control;
       detuneButtonState = !detuneButtonState;
       value = detuneButtonState ? 1 : 0;
       cp5.getController("detuneState").setColorBackground(detuneButtonState ? color(40, 150, 90) : color(20, 49, 9));
       
    break;
    
    case "chorusState":
       address = which_control;
       chorusButtonState = !chorusButtonState;
       value = chorusButtonState ? 1 : 0;
       cp5.getController("chorusState").setColorBackground(chorusButtonState ? color(40, 150, 90) : color(20, 49, 9));
    
    break;
    
    case "distortionState":
       address = which_control;
       distortionButtonState = !distortionButtonState;
       value = distortionButtonState ? 1 : 0;
       cp5.getController("distortionState").setColorBackground(distortionButtonState ? color(40, 150, 90) : color(20, 49, 9));

    break;
  
// ------------------- Knobs ------------------//      

    case "cutOff":
        address =  which_control;
        value = logScale((int)cutOff, 200, 40.0, 20000.0);
  
    break;
    
    case "resonance":
        address = which_control; 
        value = resonance; 
    break; 
    
    case "filterAttack":
        address = which_control; 
        value = logScale((int)filterAttack, 100, 0.1, 10); 
    break; 
    
    case "filterDecay":
        address = which_control; 
        value = logScale((int)filterDecay, 100, 0.1, 25);  
    break; 
    
    case "filterSustain":
        address = which_control; 
        value = logScale((int)filterSustain, 100, 0.1, 1); 
    break; 
    
    
// --> Chorus Knobs       

    case "chorusMix": 
       address = which_control;
       value = chorusMix;
    break;  
    
    case "chorusDepth": 
       address = which_control;
       value = chorusDepth;
    break; 
    
    case "chorusFeedback": 
       address = which_control;
       value = chorusFeedback;
    break; 
    
    case "chorusDelay": 
       address = which_control;
       value = chorusDelay;
    break; 

// --> Distortion Knobs

    case "distortionMix": 
       address = which_control;
       value = distortionMix;
    break;  
    
    case "distortionFilter": 
       address = which_control;
       value = distortionFilter;
    break; 
      

// --> Amp Knobs

    case "attack":
      address = which_control;
        value = logScale((int)attack, 100, 0.01, 0.99); 
    break;
    
    case "decay":
      address = which_control;
      value = logScale((int)decay, 100, 0, 4); 
    break;
    
    case "sustain":
      address = which_control;
      value = logScale((int)sustain, 100, 0.01, 0.99); 
    break;
    
    
    case "release":
      address = which_control;
      value = logScale((int)release, 100, 0.01, 10);   
    break;

// --> Other Knobs

    case "amp":
      address = which_control;
      value = amp;    
    break;    
    
    case "volume":
      address = which_control;
      value = volume;    
    break;
    
    case "pan":
      address = which_control; 
      value = pan; 
    break;

    case "detune":
        address =  which_control;
        value = detune;
    break;
    

// --> Dropdown Menu

    case "waveform":
      address = which_control;
      value = waveform + 1;
    break;  
    
  }
  if(address != null){
  OscMessage myMessage = new OscMessage("/" + address);
  myMessage.add(value);
  oscP5.send(myMessage, myRemoteLocation);
  }
  
}


// Function to send OSC messages from Arduino to SuperCollider
void sendOscMessage(String address, float value) {
  OscMessage myMessage = new OscMessage(address);
  myMessage.add(value);
  oscP5.send(myMessage, myRemoteLocation);
}

// This function creates a logarithic scale for the ADSR Envelopes and CutOff Knob
 
float logScale(int intValue, int maxRangeIn, float start, float end){
  float val;
  if(start == 0){
    val = pow(10, (map (intValue, 0, maxRangeIn, 0, log(end)/log(10))));
  }
  else{
    val = pow(10, (map (intValue, 0, maxRangeIn, log(start)/log(10), log(end)/log(10))));
  };
  return val;
}
