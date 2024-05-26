Server.killAll;
s.reboot;
MIDIClient.init;
MIDIIn.connectAll; // connect MIDI Input

// Square Wave definition
(

// ============================================ DEFINITIONS ==================================================== //

// In this section we will define the core elements of our design: the actual synthesizer, the buses and the FX Chain.

// -------------- BUSES DEFINITION --------------------- //

~fxBus = Bus.audio(s, 2); // Audio FX Bus : This will the sound coming from our oscillators, and will bring it to the LPF

// -------------- SYNTH Definition --------------------- //
// Here we define the sounds in our synthesizer

SynthDef(\dynamicLPF, { |freq=440, amp=0.1, gate=0, detune=0.1, cutOff = 500, lpfOn=0, detuneActive=0, out= 0, sin=0, square=0, saw=0, attack=0.01, decay=0, sustain=1, release=0.0, volume = 1, pan = 0.0, resonance = 1.0, filterAttack = 0.01, filterSustain = 1.00, filterDecay = 0.0, filterRelease = 0.0|
    var sourceSin, sourceSquare, sourceSaw, env, detunedSin, detunedSquare, detunedSaw, mixed, filtered, control, sig, filterEnv;

	sourceSin = SinOsc.ar(freq, mul:amp*0.3) * sin; // sinusoid wave generation
	sourceSquare = Pulse.ar(freq, mul:amp*0.3) * square; // square wave generation
	sourceSaw = Saw.ar(freq, mul:amp*0.3) * saw; // saw wave generation
	env = EnvGen.kr(Env.adsr(attack, decay, sustain, release), gate, doneAction:2);
	filterEnv = EnvGen.ar(Env.adsr(filterAttack, filterDecay, filterSustain, filterRelease), doneAction:2);
	detunedSin = SinOsc.ar(freq * (1 + detune), mul:amp*0.3) * sin * detuneActive;
	detunedSquare = Pulse.ar(freq * (1 + detune), mul:amp*0.3) * square * detuneActive; // second square wave for detuning if detuneActive=1
	detunedSaw = Saw.ar(freq * (1 + detune), mul:amp*0.3) * saw * detuneActive ;
    mixed = sourceSin + sourceSquare + sourceSaw + detunedSin + detunedSquare + detunedSaw; // mix of the two square waves
	control = lpfOn.lag(0.1); // lag for a smoother change
	filtered = Select.ar(control, [mixed, RLPF.ar(mixed, cutOff * filterEnv, resonance)]); // filter is applied if lpfOn=1
	sig = filtered * env * volume;

	Out.ar(out, Pan2.ar(sig, pan)); // output stereo
}).add;

// ---------------- FX Chain Definition ---------------------- //

// FX Chain
SynthDef(\fxChain, { |bus, fx1 = 2, mix, fx2 = 2|
	var plugin = In.ar(bus, 2);
	plugin = VSTPlugin.ar(plugin, 2, fx2, id:\distortion);
	plugin = VSTPlugin.ar(plugin, 2, fx1, id:\chorus);
    Out.ar(bus, plugin);

}).add;

	~fxSynth = Synth(\fxChain, [\bus, ~fxBus], addAction: \addToTail);

SynthDef(\output, { arg in = 0, out = 0;
    Out.ar(out, In.ar(in, 2))
	}).play(1 ,[\in, ~fxBus, \out, 0], addAction: \addToTail);


	~fx = VSTPluginController.collect(~fxSynth);
	~fx.distortion.open("SubDominant.vst3");
	~fx.chorus.open("basicChorus.vst3");




//=====================================================================

// MIDI Note ON/OFF
~midiChannel = 0; // define the MIDI channel
~notes = Array.newClear(128); // define number of notes

// Define a function to run the Synth when a MIDI note is pressed
MIDIdef.noteOn(\startSynth, { |vel, note, chan|

	if(chan == ~midiChannel, {

        ~notes[note] = Synth.new(
			\dynamicLPF,
			[
				\attack, ~attackTime,
				\decay, ~decayTime,
				\sustain, ~sustainLevel,
				\release, ~releaseTime,
				\amp, ~amp,
				\freq, note.midicps,
				\volume, ~volume,
				\pan, ~pan,
				\gate, 1,
				\lpfOn, ~filterOn,
				\cutOff, ~cutOff,
				\detuneActive, ~detuneOn,
				\detune, ~detune,
				\sin, ~sin,
				\square, ~square,
				\saw, ~saw,
				\out, ~fxBus,
				\resonance, ~resonance,
				\filterAttack, ~filterAttack,
				\filterDecay, ~filterDecay,
				\filterSustain, ~filterSustain,
				\filterRelease, ~filterRelease
			])
	});

}, chan:~midiChannel);

// Define a function to stop the Synth when a MIDI note is released
MIDIdef.noteOff(\stopSynth, { |vel, note, chan|
    if(chan == ~midiChannel, {
		~notes[note].set(\gate, 0);
		~notes[note].isPlaying.free;

		~notes[note] = nil;

    });
}, chan:~midiChannel);


//=====================================================================

// OSC Communication with Processing
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

// Master volume
~volume = 1;
OSCFunc({|msg, time, addr, recvPort|
	~volume = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
			synth.set(\volume, ~volume);
		});
	};
}, '/volume', n, 57120);

// Vocal amplitude
~amp = 1;
OSCFunc({|msg, time, addr, recvPort|
	~amp = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
			synth.set(\amp, ~amp);
		});
	};
}, '/amp', n, 57120);

// Pan
~pan = 0.0;
OSCFunc({|msg, time, addr, recvPort|
	~pan = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
			synth.set(\pan, ~pan);
		});
	};
}, '/pan', n, 57120);

// Detune ON/OFF
OSCFunc({|msg, time, addr, recvPort|
	~detuneOn = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
			synth.set(\detuneActive, ~detuneOn);
		});
	};
}, '/detuneState', n, 57120);

// Detune Amount
OSCFunc({|msg, time, addr, recvPort|
	~detune = msg[1];

	~notes.do{|synth|
		if(synth.notNil, {
			synth.set(\detune, ~detune);
		});
	};
}, '/detune', n, 57120);

// ---------------- ADSR OSC --------------- //

// Attack time
~attackTime = 0.05;
OSCFunc({|msg, time, addr, recvPort|
	~attackTime = msg[1];
}, '/attack', n, 57120);

// Decay time
~decayTime = 0.0;
OSCFunc({|msg, time, addr, recvPort|
	~decayTime = msg[1];
}, '/decay', n, 57120);

// Sustain level
~sustainLevel = 1.0;
OSCFunc({|msg, time, addr, recvPort|
	~sustainLevel = msg[1];
}, '/sustain', n, 57120);

// Release level
~releaseTime = 1.0;
OSCFunc({|msg, time, addr, recvPort|
	~releaseTime = msg[1];
}, '/release', n, 57120);

// ---------------- Filter OSC --------------- //

// Filter ON/OFF
OSCFunc({|msg, time, addr, recvPort|
	~filterOn = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
		synth.set(\lpfOn, ~filterOn);
		});
	};
}, '/cutoffState', n, 57120);

// Filter CUTOFF
OSCFunc({|msg, time, addr, recvPort|
	~cutOff = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
		synth.set(\cutOff, ~cutOff);

		});
	};
}, '/cutOff', n, 57120);

// Filter Resonance

OSCFunc({|msg, time, addr, recvPort|
	~resonance = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
		synth.set(\resonance, ~resonance);
		});
	};
}, '/resonance', n, 57120);

// Filter Env Attack
OSCFunc({|msg, time, addr, recvPort|
	~filterAttack = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
		synth.set(\filterAttack, ~filterAttack);
		});
	};
}, '/filterAttack', n, 57120);

// Filter Env Decay
OSCFunc({|msg, time, addr, recvPort|
	~filterDecay = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
		synth.set(\filterDecay, ~filterDecay);
		});
	};
}, '/filterDecay', n, 57120);

// Filter Env Sustain

OSCFunc({|msg, time, addr, recvPort|
	~filterSustain = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
		synth.set(\filterSustain, ~filterSustain);
		});
	};
}, '/filterSustain', n, 57120);

// FIlter Env Release

OSCFunc({|msg, time, addr, recvPort|
	~filterRelease = msg[1];
	~notes.do{|synth|
		if(synth.notNil, {
		synth.set(\filterRelease, ~filterRelease);
		});
	};
}, '/filterRelease', n, 57120);



// ------------- FX OSC ------------------ //

// Chorus ON/OFF
OSCFunc({|msg, time, addr, recvPort|
	~chorusToggle = msg[1];
	~fxSynth.set(\fx1, ~chorusToggle);

}, '/chorusState', n, 57120);


~chorusMix = 1;
// feed=3, delay=2, depth=1, mix=4, rate=0
// Chorus Mix
~chorusMix = 1;
OSCFunc({|msg, time, addr, recvPort|
	~chorusMix = msg[1];
	~fx.chorus.set(4, ~chorusMix);

}, '/chorusMix', n, 57120);

~chorusFeedback = 0;
// Chorus Feedback
~chorusFeedback = 0;
OSCFunc({|msg, time, addr, recvPort|
	~chorusFeedback = msg[1];
	~fx.chorus.set(3, ~chorusFeedback);

}, '/chorusFeedback', n, 57120);

// Chorus Delay
~chorusDelay= 0;
OSCFunc({|msg, time, addr, recvPort|
	~chorusDelay = msg[1];
	~fx.chorus.set(2, ~chorusDelay);

}, '/chorusDelay', n, 57120);

// Chorus Depth
~chorusDepth = 0;
OSCFunc({|msg, time, addr, recvPort|
	~chorusDepth = msg[1];
	~fx.chorus.set(1, ~chorusDepth);

}, '/chorusDepth', n, 57120);


// Distortion ON/OFF
OSCFunc({|msg, time, addr, recvPort|
	~distortionToggle = msg[1];
	~fxSynth.set(\fx2, ~distortionToggle);
}, '/distortionState', n, 57120);


// Distortion Mix
~distortionMix = 1;
OSCFunc({|msg, time, addr, recvPort|
	~distortionMix = msg[1];
	~fx.distortion.set(8, ~distortionMix);
}, '/distortionMix', n, 57120);

// Distortion Filter
~distortionFilter = 1;
OSCFunc({|msg, time, addr, recvPort|
	~distortionFilter = msg[1];
	~fx.distortion.set(4, ~distortionFilter);
}, '/distortionFilter', n, 57120);


)
