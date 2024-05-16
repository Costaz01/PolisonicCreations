
// Definizione del SynthDef per una square wave con controllo dinamico del filtro
(
SynthDef(\dynamicLPF, { |freq = 440, detune = 0.1, cutoff = 500, lpfOn = 0, detuneActive = 0|
    var source, detunedSource, mixed, filtered, control;
    source = Pulse.ar(freq, 0.5); // Genera una square wave a 440Hz con tutte le armoniche
    detunedSource = Pulse.ar(freq * (1 + detune), 0.5) * detuneActive; // Genera una seconda square wave detunata se detuneActive è 1
    mixed = source + detunedSource; // Mescola la square wave originale con quella detunata
    control = lpfOn.lag(0.1); // Aggiunge un leggero ritardo per un cambiamento più morbido
    filtered = Select.ar(control, [mixed, LPF.ar(mixed, cutoff)]); // Applica il filtro se lpfOn è 1
    Out.ar(0, filtered ! 2); // Output stereo
}).add;
)


// Avvio del server audio, se non è già attivo
s.boot;

// Esecuzione del Synth senza il filtro low pass attivo
x = Synth(\dynamicLPF);

// Filter ON/OFF
(
n = NetAddr("127.0.0.1");
OSCFunc({|msg, time, addr, recvPort|
	var button = msg[1];
	x.set(\lpfOn, button).postln;}, '/button', n, 57120);
)

// Filter CUTOFF
(
n = NetAddr("127.0.0.1");
OSCFunc({|msg, time, addr, recvPort|
	var cutoff = msg[1];
	x.set(\cutoff, cutoff).postln;}, '/cutOff', n, 57120);
)

// Detune ON/OFF
(
n = NetAddr("127.0.0.1");
OSCFunc({|msg, time, addr, recvPort|
	var val = msg[1];
	x.set(\detuneActive, val).postln;}, '/detuneButton', n, 57120);
)


// Detune Amount
(
n = NetAddr("127.0.0.1");
OSCFunc({|msg, time, addr, recvPort|
	var val = msg[1];
	x.set(\detune, val).postln;}, '/detune', n, 57120);
)

OSCFunc.trace(true);




