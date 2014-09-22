var 口 = require('midiguchi');
var piu = require('piu');
var teoria = require('teoria');

var onNotes = {};

var NOTE_ON = 0x90;
var NOTE_OFF = 0x80;
function eventType(message) {
	return message[0] & 0xf0;
}

function printChord() {
	var notes = [];
	for (var note in onNotes) {
		notes.push(teoria.note.fromMIDI(note));
	}
	var chords = piu.infer(notes, true);
	console.log(notes.map(function(n) { return n.name() + n.accidental() }));
	console.log(chords.map(piu.name));
}

function handleMidi(message) {
	var m = message[0];
	var type = eventType(message);
	var note = message[1];
	var vel = message[2];
	if (type == NOTE_ON && vel > 0) {
		onNotes[note] = true;
	} else if (type == NOTE_OFF || type == NOTE_ON) {
		delete onNotes[note];
	} else {
		return;
	}

	printChord();
}

console.log(口.input.ports[0]);
if (口.input.ports.length == 0) {
	throw new Error("No MIDI devices found.  Connect one and try again.");
}

口.input.ports.forEach(function(port) {
	console.log("Opening MIDI port: " + port);
	口.input.open(port).onValue(handleMidi);
});

// input.closePort();