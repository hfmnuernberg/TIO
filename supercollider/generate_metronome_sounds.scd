( // setup and boot
~sr = 44100;
s.options.sampleRate_(~sr);
s.boot()
~outPath = "/Users/fluffy/projects/TIO/supercollider/"
)

// BOP
(
var name = "blup_a";
var dur = 0.08;
b = Buffer.alloc(s, ~sr * dur, 1);
{
	var freq = 69.midicps;
	var snd = SinOscFB.ar(freq, 0.1);
	var env = EnvGen.kr(Env.perc(0.01, 0.05), doneAction:2);
	snd = snd * env;
	RecordBuf.ar(snd, b)
}.play;
fork {
	0.3.wait;
	b.write((~outPath ++ name ++ ".wav").postln, headerFormat:"wav");
};
)
(
var name = "blup";
var dur = 0.08;
b = Buffer.alloc(s, ~sr * dur, 1);
{
	var freq = 60.midicps;
	var snd = SinOscFB.ar(freq, 0.1);
	var env = EnvGen.kr(Env.perc(0.01, 0.05), doneAction:2);
	snd = snd * env;
	RecordBuf.ar(snd, b);
	snd
}.play;
fork {
	0.3.wait;
	b.write((~outPath ++ name ++ ".wav").postln, headerFormat:"wav");
};
)



// digi click
(
var name = "digi click_a";
var dur = 0.1;
b = Buffer.alloc(s, ~sr * dur, 1);
{
	var freq = (60+12).midicps;
	var snd = Pulse.ar(freq, 0.1);
	var env = EnvGen.kr(Env.perc(0.008, 0.02), doneAction:2);
	snd = snd * env;
	RecordBuf.ar(snd, b)
}.play;
fork {
	0.3.wait;
	b.write((~outPath ++ name ++ ".wav").postln, headerFormat:"wav");
};
)
(
var name = "digi click";
var dur = 0.1;
b = Buffer.alloc(s, ~sr * dur, 1);
{
	var freq = (60).midicps;
	var snd = Pulse.ar(freq, 0.1);
	var env = EnvGen.kr(Env.perc(0.008, 0.02), doneAction:2);
	snd = snd * env;
	RecordBuf.ar(snd, b)
}.play;
fork {
	0.3.wait;
	b.write((~outPath ++ name ++ ".wav").postln, headerFormat:"wav");
};
)


// noise
(
var name = "noise_a";
var dur = 0.1;
b = Buffer.alloc(s, ~sr * dur, 1);
{
	var snd = LPF.ar(WhiteNoise.ar(), 5000);
	var env = EnvGen.kr(Env.perc(0.008, 0.04), doneAction:2);
	snd = snd * env;
	RecordBuf.ar(snd, b)
}.play;
fork {
	0.3.wait;
	b.write((~outPath ++ name ++ ".wav").postln, headerFormat:"wav");
};
)
(
var name = "noise";
var dur = 0.1;
b = Buffer.alloc(s, ~sr * dur, 1);
{
	var snd = LPF.ar(WhiteNoise.ar(), 2000);
	var env = EnvGen.kr(Env.perc(0.008, 0.04), doneAction:2);
	snd = snd * env;
	RecordBuf.ar(snd, b)
}.play;
fork {
	0.3.wait;
	b.write((~outPath ++ name ++ ".wav").postln, headerFormat:"wav");
};
)


// noise
(
var name = "kick_a";
var dur = 0.1;
b = Buffer.alloc(s, ~sr * dur, 1);
{
	var snd = SinOscFB.ar(Line.kr(300, 10, 0.01), 0.9);
	var env = EnvGen.kr(Env.perc(0.01, 0.02), doneAction:2);
	snd = Fold.ar(snd, -0.7, 0.7);
	snd = snd * env;
	RecordBuf.ar(snd, b)
}.play;
fork {
	0.3.wait;
	b.write((~outPath ++ name ++ ".wav").postln, headerFormat:"wav");
};
)
(
var name = "kick";
var dur = 0.1;
b = Buffer.alloc(s, ~sr * dur, 1);
{
	var snd = SinOscFB.ar(Line.kr(280, 10, 0.009), 0.9);
	var env = EnvGen.kr(Env.perc(0.008, 0.011), doneAction:2);
	snd = snd * env;
	RecordBuf.ar(snd, b)
}.play;
fork {
	0.3.wait;
	b.write((~outPath ++ name ++ ".wav").postln, headerFormat:"wav");
};
)


// click
(
var name = "pling_a";
var dur = 0.07;
b = Buffer.alloc(s, ~sr * dur, 1);
{
	var snd = SinOscFB.ar(2000, 0.2);
	var env = EnvGen.kr(Env.perc(0.002, 0.05), doneAction:2);
	snd = snd * env;
	RecordBuf.ar(snd, b)
}.play;
fork {
	0.3.wait;
	b.write((~outPath ++ name ++ ".wav").postln, headerFormat:"wav");
};
)
(
var name = "pling";
var dur = 0.07;
b = Buffer.alloc(s, ~sr * dur, 1);
{
	var snd = SinOscFB.ar(1000, 0.2);
	var env = EnvGen.kr(Env.perc(0.002, 0.05), doneAction:2);
	snd = snd * env;
	RecordBuf.ar(snd, b)
}.play;
fork {
	0.3.wait;
	b.write((~outPath ++ name ++ ".wav").postln, headerFormat:"wav");
};
)