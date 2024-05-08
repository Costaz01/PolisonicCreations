s.reboot;

(
MIDIClient.init; // Inizializza il client MIDI
MIDIIn.connectAll; // Connette tutte le sorgenti MIDI disponibili

// Definisci una SynthDef con un argomento per la frequenza controllata da MIDI
SynthDef(\sinewave, { |freq = 440|
    Out.ar(0, SinOsc.ar(freq) * 0.2)
}).add;

// Crea un'istanza del synth
~synth = Synth(\sinewave);

// Crea una funzione per gestire i messaggi MIDI di controllo
~midiControl = { |val|
    ~synth.set(\freq, val.midicps); // Converte il valore MIDI in frequenza e imposta il parametro del synth
};

// Assegna la funzione di controllo MIDI al canale e al numero di controllo corretti
MIDIdef.cc(\myControl, ~midiControl, 74, 1); // 74 è il numero di controllo, 1 è il canale MIDI
)


