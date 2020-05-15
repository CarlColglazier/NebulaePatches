// An attempt at pulsar synthesis in Supercollider.
s.waitForBoot {
	~rPort = 3000;

	"Booted".postln;
	"Pulsar synthesis patch".postln;

	SynthDef(\grain, {
		| freq = 220, pulse = 0.3, speed = 1, waveform = 0 |
		var o, env, sig, class, f;
		f = speed * freq / pulse;
		o = Select.ar(waveform, [
			SinOsc.ar(f),  // 0
			Impulse.ar(f), // 1
			Saw.ar(f),     // 2
			WhiteNoise.ar()// 3
		]);
		//o = class;
		env = EnvGen.ar(
			Env.new(
				levels: [0, 1, 1, 0],
				times: [0, 0.00001, (1 / freq) * pulse]
			),
			doneAction: 2
		);
		sig = env * o;
		Out.ar(0, sig!2);
	}).add;

	// This Pdef handles the loop.
	// Runs continuously.
	Pdefn(\freq, 220);
	Pdefn(\speed, 1);
	Pdefn(\pulse, 0.5);
	Pdefn(\waveform, 0);
	Pdef(\psar,
		Pbind(
			\instrument, \grain,
			\freq, Pdefn(\freq);,
			\dur, 1 / Pdefn(\freq),
			\pulse, Pdefn(\pulse),
			\speed, Pdefn(\speed),
			\waveform, Pdefn(\waveform)
		)
	).play;

	// Knobs
	OSCdef( \osc_speed, {
		arg msg, time, addr, recvPort;
		var arr, ind;
		a = [1/8, 1/4, 1/2, 1, 2, 4, 8];
		Pdefn(\speed, a.at(msg[1].linlin(0, 1, 0, 6).round));
	},
	'/neb/speed',recvPort:~rPort);

	OSCdef( \osc_pitch, {
		arg msg, time, addr, recvPort;
		var freq;
		// Assume these go between zero and one.
		freq = 16.352 * (2**(msg[1] * 5));
		Pdefn(\freq, freq);
	},
	'/neb/pitch',recvPort:~rPort);

	OSCdef( \osc_start, {
		arg msg, time, addr, recvPort;
		a = [0, 1, 2, 3];
		Pdefn(\waveform, a.at(msg[1].linlin(0, 1, 0, 3).round));
	},
	'/neb/start',recvPort:~rPort);

	OSCdef( \osc_overlap, {
		arg msg, time, addr, recvPort;
		Pdefn(\pulse, msg[1]);
	},
	'/neb/overlap',recvPort:~rPort);
};

/*
s.scope;
Pdefn(\pulse, 0.1)
Pdefn(\freq, 110)
Pdefn(\speed, 1);
Pdefn(\waveform, 3);
*/