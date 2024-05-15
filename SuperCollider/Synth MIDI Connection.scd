s.reboot;

(
SynthDef(\FMSynth,
    {
        arg freq = 440, mul = 1, outBus = 0;
		var source;
		source = SinOsc.ar(freq, 0.0, mul);
        Out.ar(outBus, source);
    }
).add )

(
SynthDef(\LPFilter,
	{
		arg outBus = 0, freqfilter = 1000;
		var sig, imp;

		sig = PlayBuf.ar(1, outBus, 1, doneAction:0);
		b = BLowPass(sig, \freq, freqfilter, \rq, 1);
		Out.ar(outBus);
}).add;
)



(
var bus = Bus.audio(s);
x= Synth(\FMSynth,[\freq, 440, \mul, 0.0, \outBus, 0]);
)


(
n = NetAddr("127.0.0.1");
OSCFunc({|msg, time, addr, recvPort|
	var freq = msg[1].asFloat;
	var mul = msg[2].asFloat;
	postln(mul);
	x.set(\freq, freq, \mul, mul).postln}, '/FMSynth/control', n, 57120);
)


OSCFunc.trace(true);
