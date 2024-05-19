s.reboot;
MIDIClient.init;
MIDIIn.connectAll; // connect MIDI Input

// Square Wave definition
(
SynthDef(\dynamicLPF, { |freq=440, amp=0.3, gate=0, detune=0.1, cutOff=500, lpfOn=0, detuneActive=0, out=0, sin=0, square=0, saw=0|
    var sourceSin, sourceSquare, sourceSaw, env, detunedSin, detunedSquare, detunedSaw, mixed, filtered, control, sig;
	sourceSin = SinOsc.ar(freq, amp) * sin; // sin wave generation
	sourceSquare = Pulse.ar(freq, amp) * square; // square wave generation
	sourceSaw = Saw.ar(freq,amp) * saw; // saw wave generation
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	detunedSin = SinOsc.ar(freq * (1 + detune), amp) * sin * detuneActive;
    detunedSquare = Pulse.ar(freq * (1 + detune), amp) * square * detuneActive; // second square wave for detuning if detuneActive=1
	detunedSaw = Saw.ar(freq * (1 + detune), amp) * saw * detuneActive;
    mixed = sourceSin + sourceSquare + sourceSaw + detunedSin + detunedSquare + detunedSaw; // mix of the two square waves
    control = lpfOn.lag(0.1); // lag for a smoother change
    filtered = Select.ar(control, [mixed, LPF.ar(mixed, cutOff)]); // filter is applied if lpfOn=1
	sig = filtered * env;
    Out.ar(out, sig ! 2); // output stereo
}).add;
)

//=====================================================================

// MIDI Note ON/OFF
(
~midiChannel = 0; // define the MIDI channel
~notes = Array.newClear(128); // define number of notes

// Define a function to run the Synth when a MIDI note is pressed
MIDIdef.noteOn(\startSynth, { |vel, note, chan|
    if(chan == ~midiChannel, {
        ~notes[note] = Synth.new(
			\dynamicLPF,
			[
				\freq, note.midicps,
				\amp, vel.linexp(1,127,0.01,0.3),
				\gate, 1,
				\lpfOn, ~filterOn,
				\cutOff, ~cutOff,
				\detuneActive, ~detuneOn,
				\detune, ~detune,
				\sin, ~sin,
				\square, ~square,
				\saw, ~saw
			]
	)});
}, chan:~midiChannel);

// Define a function to stop the Synth when a MIDI note is released
MIDIdef.noteOff(\stopSynth, { |vel, note, chan|
    if(chan == ~midiChannel, {
		~notes[note].set(\gate, 0);
		~notes[note] = nil;
    });
}, chan:~midiChannel);
)

//=====================================================================

// OSC Communication with Processing
(
n = NetAddr("127.0.0.1"); // set the receiving address for OSC Messages

// Waveform Selection
~waveform = 0;
~sin = 0;
~square = 0;
~saw = 0;
OSCFunc({ |msg, time, addr, recvPort|
    ~waveform = msg[1];
    if(~waveform == 1, {
		~sin = 1;
		~square = 0;
		~saw = 0;
        ~notes.do { |synth|
            if(synth.notNil, {
                synth.set(\sin, ~sin, \square, ~square, \saw, ~saw);
            });
        };
    }, {
        if(~waveform == 2, {
			~sin = 0;
		    ~square = 1;
			~saw = 0;
            ~notes.do { |synth|
                if(synth.notNil, {
                    synth.set(\sin, ~sin, \square, ~square, \saw, ~saw);
                });
            };
        }, {
            if(~waveform == 3, {
				~sin = 0;
				~square = 0;
				~saw = 1;
                ~notes.do { |synth|
                    if(synth.notNil, {
                        synth.set(\sin, ~sin, \square, ~square, \saw, ~saw);
                    });
                };
            });
        });
    });
}, '/waveform', n, 57120);

// Filter ON/OFF
OSCFunc({|msg, time, addr, recvPort|
	~filterOn = msg[1];
	~notes.do{|synth|
		synth.set(\lpfOn, ~filterOn);
		};
}, '/button', n, 57120);

// Filter CUTOFF
OSCFunc({|msg, time, addr, recvPort|
	~cutOff = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
			synth.set(\cutOff, ~cutOff);
		});
	};
}, '/cutOff', n, 57120);

// Detune ON/OFF
OSCFunc({|msg, time, addr, recvPort|
	~detuneOn = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
			synth.set(\detuneActive, ~detuneOn);
		});
	};
}, '/detuneButton', n, 57120);

// Detune Amount
OSCFunc({|msg, time, addr, recvPort|
	~detune = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
			synth.set(\detune, ~detune);
		});
	};
}, '/detune', n, 57120);
)

//=====================================================================

// Open Chourus Plugin
(
SynthDef(\chorus, {|in, out|
	var sound = In.ar(in, 2);
	ReplaceOut.ar(out, VSTPlugin.ar(sound, 2, id: \chorus));
}).add;
)
~chorusBus = Bus.audio(s, 2);

~chorus = VSTPluginController(Synth(\chorus, [\in, ~chorusBus, \out, 0]), id: \chorus);
~chorus.open("basicChorus.vst3", editor: true, verbose: true);
~chorus.editor;

(
// Send Audio into VST
Pdef(\seq,
	Pbind(
		\instument, \dynamicLPF,
		\out, ~chorusBus,
		\scale, Scale.minor,
		\octave, Prand([3,4,5],inf),
		\degree, Pwhite(0,7,inf),
		\dur, Prand([Pseq([0.25,0.25,0.25,0.25],1), Pseq([0.5,0.5],1),1],inf),
));
)

Pdef(\seq).play(quant:1);


OSCFunc.trace(true);
OSCFunc.trace(false);

VSTPlugin.search;
VSTPlugin.pluginList;

