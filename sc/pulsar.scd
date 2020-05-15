// An attempt at pulsar synthesis in Supercollider.
(
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
)

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
).stop;
)
Pdefn(\dur, 1 / 110);
Pdefn(\freq, 100);
