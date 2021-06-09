/*-
 * Copyright © 2020, 2021
 *	mirabilos <m@mirbsd.org>
 *
 * Provided that these terms and disclaimer and all copyright notices
 * are retained or reproduced in an accompanying document, permission
 * is granted to deal in this work without restriction, including un‐
 * limited rights to use, publicly perform, distribute, sell, modify,
 * merge, give away, or sublicence.
 *
 * This work is provided “AS IS” and WITHOUT WARRANTY of any kind, to
 * the utmost extent permitted by applicable law, neither express nor
 * implied; without malicious intent or gross negligence. In no event
 * may a licensor, author or contributor be held liable for indirect,
 * direct, other damage, loss, or other issues arising in any way out
 * of dealing in the work, even if advised of the possibility of such
 * damage or existence of a defect, except proven that it results out
 * of said person’s immediate fault when using the work as intended.
 *-
 * Name notes of chords as stafftext in voice order.
 *
 * Makes use of some techniques demonstrated by the MuseScore example
 * plugins. No copyright is claimed for these or the API extracts.
 */

import MuseScore 3.0

MuseScore {
	description: "This plugin inserts the names of the notes in the chords, by voice, as staff text.";
	requiresScore: true;
	version: "1";
	menuPath: "Plugins.Notes.Note Names as Staff Text";

	function buildMeasureMap(score) {
		var map = {};
		var no = 1;
		var cursor = score.newCursor();
		cursor.rewind(Cursor.SCORE_START);
		while (cursor.measure) {
			var m = cursor.measure;
			var tick = m.firstSegment.tick;
			var tsD = m.timesigActual.denominator;
			var tsN = m.timesigActual.numerator;
			var ticksB = division * 4.0 / tsD;
			var ticksM = ticksB * tsN;
			no += m.noOffset;
			var cur = {
				"tick": tick,
				"tsD": tsD,
				"tsN": tsN,
				"ticksB": ticksB,
				"ticksM": ticksM,
				"past" : (tick + ticksM),
				"no": no
			};
			map[cur.tick] = cur;
			console.log(tsN + "/" + tsD + " measure " + no +
			    " at tick " + cur.tick + " length " + ticksM);
			if (!m.irregular)
				++no;
			cursor.nextMeasure();
		}
		return map;
	}

	function showPos(cursor, measureMap) {
		var t = cursor.segment.tick;
		var m = measureMap[cursor.measure.firstSegment.tick];
		var b = "?";
		if (m && t >= m.tick && t < m.past) {
			b = 1 + (t - m.tick) / m.ticksB;
		}

		return "St" + (cursor.staffIdx + 1) +
		    " Vc" + (cursor.voice + 1) +
		    " Ms" + m.no + " Bt" + b;
	}

	function nameElementType(elementType) {
		switch (elementType) {
		case Element.ACCIDENTAL:
			return "ACCIDENTAL";
		case Element.AMBITUS:
			return "AMBITUS";
		case Element.ARPEGGIO:
			return "ARPEGGIO";
		case Element.ARTICULATION:
			return "ARTICULATION";
		case Element.BAGPIPE_EMBELLISHMENT:
			return "BAGPIPE_EMBELLISHMENT";
		case Element.BAR_LINE:
			return "BAR_LINE";
		case Element.BEAM:
			return "BEAM";
		case Element.BEND:
			return "BEND";
		case Element.BRACKET:
			return "BRACKET";
		case Element.BRACKET_ITEM:
			return "BRACKET_ITEM";
		case Element.BREATH:
			return "BREATH";
		case Element.CHORD:
			return "CHORD";
		case Element.CHORDLINE:
			return "CHORDLINE";
		case Element.CLEF:
			return "CLEF";
		case Element.COMPOUND:
			return "COMPOUND";
		case Element.DYNAMIC:
			return "DYNAMIC";
		case Element.ELEMENT:
			return "ELEMENT";
		case Element.ELEMENT_LIST:
			return "ELEMENT_LIST";
		case Element.FBOX:
			return "FBOX";
		case Element.FERMATA:
			return "FERMATA";
		case Element.FIGURED_BASS:
			return "FIGURED_BASS";
		case Element.FINGERING:
			return "FINGERING";
		case Element.FRET_DIAGRAM:
			return "FRET_DIAGRAM";
		case Element.FSYMBOL:
			return "FSYMBOL";
		case Element.GLISSANDO:
			return "GLISSANDO";
		case Element.GLISSANDO_SEGMENT:
			return "GLISSANDO_SEGMENT";
		case Element.HAIRPIN:
			return "HAIRPIN";
		case Element.HAIRPIN_SEGMENT:
			return "HAIRPIN_SEGMENT";
		case Element.HARMONY:
			return "HARMONY";
		case Element.HBOX:
			return "HBOX";
		case Element.HOOK:
			return "HOOK";
		case Element.ICON:
			return "ICON";
		case Element.IMAGE:
			return "IMAGE";
		case Element.INSTRUMENT_CHANGE:
			return "INSTRUMENT_CHANGE";
		case Element.INSTRUMENT_NAME:
			return "INSTRUMENT_NAME";
		case Element.JUMP:
			return "JUMP";
		case Element.KEYSIG:
			return "KEYSIG";
		case Element.LASSO:
			return "LASSO";
		case Element.LAYOUT_BREAK:
			return "LAYOUT_BREAK";
		case Element.LEDGER_LINE:
			return "LEDGER_LINE";
		case Element.LET_RING:
			return "LET_RING";
		case Element.LET_RING_SEGMENT:
			return "LET_RING_SEGMENT";
		case Element.LYRICS:
			return "LYRICS";
		case Element.LYRICSLINE:
			return "LYRICSLINE";
		case Element.LYRICSLINE_SEGMENT:
			return "LYRICSLINE_SEGMENT";
		case Element.MARKER:
			return "MARKER";
		case Element.MEASURE:
			return "MEASURE";
		case Element.MEASURE_LIST:
			return "MEASURE_LIST";
		case Element.MEASURE_NUMBER:
			return "MEASURE_NUMBER";
		case Element.NOTE:
			return "NOTE";
		case Element.NOTEDOT:
			return "NOTEDOT";
		case Element.NOTEHEAD:
			return "NOTEHEAD";
		case Element.NOTELINE:
			return "NOTELINE";
		case Element.OSSIA:
			return "OSSIA";
		case Element.OTTAVA:
			return "OTTAVA";
		case Element.OTTAVA_SEGMENT:
			return "OTTAVA_SEGMENT";
		case Element.PAGE:
			return "PAGE";
		case Element.PALM_MUTE:
			return "PALM_MUTE";
		case Element.PALM_MUTE_SEGMENT:
			return "PALM_MUTE_SEGMENT";
		case Element.PART:
			return "PART";
		case Element.PEDAL:
			return "PEDAL";
		case Element.PEDAL_SEGMENT:
			return "PEDAL_SEGMENT";
		case Element.REHEARSAL_MARK:
			return "REHEARSAL_MARK";
		case Element.REPEAT_MEASURE:
			return "REPEAT_MEASURE";
		case Element.REST:
			return "REST";
		case Element.SCORE:
			return "SCORE";
		case Element.SEGMENT:
			return "SEGMENT";
		case Element.SELECTION:
			return "SELECTION";
		case Element.SHADOW_NOTE:
			return "SHADOW_NOTE";
		case Element.SLUR:
			return "SLUR";
		case Element.SLUR_SEGMENT:
			return "SLUR_SEGMENT";
		case Element.SPACER:
			return "SPACER";
		case Element.STAFF:
			return "STAFF";
		case Element.STAFFTYPE_CHANGE:
			return "STAFFTYPE_CHANGE";
		case Element.STAFF_LINES:
			return "STAFF_LINES";
		case Element.STAFF_LIST:
			return "STAFF_LIST";
		case Element.STAFF_STATE:
			return "STAFF_STATE";
		case Element.STAFF_TEXT:
			return "STAFF_TEXT";
		case Element.STEM:
			return "STEM";
		case Element.STEM_SLASH:
			return "STEM_SLASH";
		case Element.STICKING:
			return "STICKING";
		case Element.SYMBOL:
			return "SYMBOL";
		case Element.SYSTEM:
			return "SYSTEM";
		case Element.SYSTEM_DIVIDER:
			return "SYSTEM_DIVIDER";
		case Element.SYSTEM_TEXT:
			return "SYSTEM_TEXT";
		case Element.TAB_DURATION_SYMBOL:
			return "TAB_DURATION_SYMBOL";
		case Element.TBOX:
			return "TBOX";
		case Element.TEMPO_TEXT:
			return "TEMPO_TEXT";
		case Element.TEXT:
			return "TEXT";
		case Element.TEXTLINE:
			return "TEXTLINE";
		case Element.TEXTLINE_BASE:
			return "TEXTLINE_BASE";
		case Element.TEXTLINE_SEGMENT:
			return "TEXTLINE_SEGMENT";
		case Element.TIE:
			return "TIE";
		case Element.TIE_SEGMENT:
			return "TIE_SEGMENT";
		case Element.TIMESIG:
			return "TIMESIG";
		case Element.TREMOLO:
			return "TREMOLO";
		case Element.TREMOLOBAR:
			return "TREMOLOBAR";
		case Element.TRILL:
			return "TRILL";
		case Element.TRILL_SEGMENT:
			return "TRILL_SEGMENT";
		case Element.TUPLET:
			return "TUPLET";
		case Element.VBOX:
			return "VBOX";
		case Element.VIBRATO:
			return "VIBRATO";
		case Element.VIBRATO_SEGMENT:
			return "VIBRATO_SEGMENT";
		case Element.VOLTA:
			return "VOLTA";
		case Element.VOLTA_SEGMENT:
			return "VOLTA_SEGMENT";
		default:
			return "(Element." + (elementType + 0) + ")";
		}
	}

	/** signature: applyToSelectionOrScore(cb, ...args) */
	function applyToSelectionOrScore(cb) {
		var args = Array.prototype.slice.call(arguments, 1);
		var staveBeg;
		var staveEnd;
		var tickEnd;
		var rewindMode;
		var toEOF;

		var cursor = curScore.newCursor();
		cursor.rewind(Cursor.SELECTION_START);
		if (cursor.segment) {
			staveBeg = cursor.staffIdx;
			cursor.rewind(Cursor.SELECTION_END);
			staveEnd = cursor.staffIdx;
			if (!cursor.tick) {
				/*
				 * This happens when the selection goes to the
				 * end of the score — rewind() jumps behind the
				 * last segment, setting tick = 0.
				 */
				toEOF = true;
			} else {
				toEOF = false;
				tickEnd = cursor.tick;
			}
			rewindMode = Cursor.SELECTION_START;
		} else {
			/* no selection */
			staveBeg = 0;
			staveEnd = curScore.nstaves - 1;
			toEOF = true;
			rewindMode = Cursor.SCORE_START;
		}

		for (var stave = staveBeg; stave <= staveEnd; ++stave) {
			for (var voice = 0; voice < 4; ++voice) {
				cursor.staffIdx = stave;
				cursor.voice = voice;
				cursor.rewind(rewindMode);
				/*XXX https://musescore.org/en/node/301846 */
				cursor.staffIdx = stave;
				cursor.voice = voice;

				while (cursor.segment &&
				    (toEOF || cursor.tick < tickEnd)) {
					if (cursor.element)
						cb.apply(null,
						    [cursor].concat(args));
					cursor.next();
				}
			}
		}
	}

	function dropLyrics(cursor, measureMap) {
		//XXX delete all staff text?
	}

	function nameNote(note) {
		var octave = Math.floor(note.pitch / 12) - 1;
		var tpc = note.tpc1 + 1;
		var toneclass = Math.floor(tpc / 7);
		var tonenote = tpc % 7;

		var name = ["F", "C", "G", "D", "A", "E", "B"][tonenote];
		name += ["𝄫", "♭", "", "♯", "𝄪"][toneclass];
		switch (tpc) {
		case 34:
		case 27:
			--octave;
			break;
		case 8:
		case 1:
			++octave;
			break;
		}
		name += ["₋₁", "₀", "₁", "₂", "₃", "₄", "₅", "₆", "₇",
		    "₈", "₉"][octave + 1];

		return name; // + "(" + note.tpc1 + "/" + note.pitch + ")";
	}

	function nameNotes(cursor, measureMap) {
		//console.log(showPos(cursor, measureMap) + ": " +
		//    nameElementType(cursor.element.type));
		if (cursor.element.type !== Element.CHORD)
			return;

		var text = newElement(Element.STAFF_TEXT);
		text.text = "";
		var notes = cursor.element.notes;
		var sep = "";
		for (var i = 0; i < notes.length; ++i) {
			text.text += sep + nameNote(notes[i]);
			sep = "–";
		}
		if (text.text == "")
			return;
		text.placement = Placement.BELOW;
		text.autoplace = false;
		for (var verse = 0; verse < cursor.voice; ++verse)
			text.text = '\n' + text.text;
		//console.log(showPos(cursor, measureMap) + ": add verse(" +
		//    (text.verse + 1) + ")=" + text.text);
		cursor.add(text);
	}

	onRun: {
		var measureMap = buildMeasureMap(curScore);
		if (removeElement)
			applyToSelectionOrScore(dropLyrics, measureMap);
		applyToSelectionOrScore(nameNotes, measureMap);

		Qt.quit();
	}
}
