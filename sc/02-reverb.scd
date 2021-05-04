s.options.memSize_(65536 * 4);

s.waitForBoot {
	~rPort = 3000;

	"Booted".postln;
	SynthDef(\ReverbR, {
		arg out, mix = 1.0, t60 = 1.0, damp = 0.7, size=1.0, earlyDiff = 1.0;
		var dry, wet, sig;
		dry = SoundIn.ar([0,1]);
		wet = {
			JPverb.ar(dry, t60: t60 * 15.0, damp: damp, size:size*5.0, earlyDiff:earlyDiff);
		};
		sig = XFade2.ar(dry, wet, mix*2-1);
		Out.ar(out, sig);
    }).add;

	// Need this for the SynthDef to run.
	s.sync;

	~synth = Synth.new(\ReverbR, [\out, 0]);

	// start knob
	OSCdef( \osc_start, {
		arg msg, time, addr, recvPort;
		~synth.set(\earlyDiff, msg[1]);
	}, '/neb/start',recvPort:~rPort);
	// density
	OSCdef( \osc_density, {
		arg msg, time, addr, recvPort;
		~synth.set(\damp, msg[1]);
	}, '/neb/density',recvPort:~rPort);
	// blend knob
	OSCdef( \osc_blend, {
		arg msg, time, addr, recvPort;
		~synth.set(\mix, msg[1]);
	}, '/neb/blend',recvPort:~rPort);
	// window knob
	OSCdef( \osc_window, {
		arg msg, time, addr, recvPort;
		~synth.set(\t60, msg[1]);
	}, '/neb/window',recvPort:~rPort);
	// size knob
	OSCdef( \osc_size, {
		arg msg, time, addr, recvPort;
		~synth.set(\size, msg[1]);
	},'/neb/size',recvPort:~rPort);
};

