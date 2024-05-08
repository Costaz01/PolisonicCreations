s.boot;

(
SynthDef(\fmSynth,
    {
        arg freq = 440, modIndex = 3, modPartial = 1,
        carPartial = 1, level = 0.05, outBus = 0,
        effectBus, direct = 0.33;
        var modSig, outSig;
        modSig = SinOsc.ar(freq*modPartial,0,freq*modIndex);
        outSig = SinOsc.ar(freq * carPartial + modSig,0,level);
 Out.ar(effectBus,outSig * (1 - direct));
        Out.ar(outBus,(outSig * direct).dup);
    }
).add )

(
var bus = Bus.audio(s);
x= Synth(\fmSynth,[\freq,440,\modIndex,2,\modPartial,2.4,\outBus,0,\level,0.1]);
y= Synth.after(x,[\inBus,bus,\outBus,0]);
)

(
n = NetAddr("127.0.0.1");
OSCFunc.newMatching({|msg, time, addr, recvPort| x.set(\freq,msg[1]).postln}, '/FMSynth/freq', n);
//OSCFunc.newMatching({|msg, time, addr, recvPort|x.set(\direct,msg[1]).postln}, '/FMSynth/reverb', n);
)
