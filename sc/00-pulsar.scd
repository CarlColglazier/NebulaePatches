// An attempt at pulsar synthesis in Supercollider.
s.waitForBoot {
	~rPort = 3000;
	
	"Booted".postln;
	"Pulsar synthesis patch".postln;

	SynthDef(\grain, {
		| freq = 220, pulse = 0.3|
		var o, env;
		o = SinOsc.ar(freq / pulse);
		env = EnvGen.ar(
			Env.new(
				levels: [0, 1, 1, 0],
				times: [0, 0.00001, (1 / freq) * pulse]
			),
			doneAction: 2
		);
		Out.ar([0, 1], o * env);
	}).add;

	// This Pdef handles the loop.
	// Runs continuously.
	(
		Pdefn(\freq, 220);
		Pdefn(\dur, 1 / 220);
		Pdefn(\pulse, 0.5);
		Pdef(\psar,
			Pbind(
				\instrument, \grain,
				\freq, Pdefn(\freq);,
				\dur, Pdefn(\dur),
				\pulse, Pdefn(\pulse)
			)
		).play;
	)

	// Knobs
	(
		OSCdef( \osc_pitch, {
			arg msg, time, addr, recvPort;
			var freq;
			// Assume these go between zero and one.
			freq = 16.352 * (2**(msg[1] * 5))
			Pdefn(\dur, 1 / freq);
		},
			'/neb/pitch',recvPort:~rPort);
	)
};