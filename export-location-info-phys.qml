/*-
 * Copyright © 2020, 2021, 2024
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
 * Generate audio timing / score position correlation information and
 * save as “.locinfo.jsn” file. This version uses “physical” location
 * (measures as they are saved in the XML).
 *
 * Makes use of some techniques demonstrated by the MuseScore example
 * plugins. No copyright is claimed for these or the API extracts.
 */

import MuseScore 3.0
import QtQuick 2.0
import QtQuick.Dialogs 1.2
import FileIO 3.0

MuseScore {
	description: "This mu͒3 plugin exports score location timing information.";
	requiresScore: true;
	version: "1";
	menuPath: "Plugins.Export location info (phys)";

	id: exportLocationInfoPhys
	Component.onCompleted: {
		// runs once before console.log is ready
		if (mscoreMajorVersion >= 4) {
			exportLocationInfoPhys.title = "Export location info (phys)";
		}
	}

	MessageDialog {
		id: resultBox
		title: "Export location info (phys) result"
		icon: StandardIcon.Critical
		text: "An error occurred. Check console.log for more detail"
	}

	FileIO {
		id: outfile
		onError: console.log("E: FileIO(" + outfile.source + "): " + msg)
	}

	FileDialog {
		id: fileDialogue
		title: "Save locinfo file into…"
		folder: "file://" + outfile.tempPath()
		selectFolder: true
		onAccepted: {
			exportLocationInfoPhys.analyseScore();
			resultBox.open();
		}
		onRejected: {
			console.log("I: user cancelled file dialogue");
		}
	}

	function buildMeasureMap(score) {
		var map = {};
		var mlist = [];
		var no = 0;
		var cursor = score.newCursor();
		cursor.rewind(Cursor.SCORE_START);
		while (cursor.measure) {
			var m = cursor.measure;
			var tick = m.firstSegment.tick;
			var tsD = m.timesigActual.denominator;
			var tsN = m.timesigActual.numerator;
			var ticksB = division * 4.0 / tsD;
			var ticksM = ticksB * tsN;
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
			mlist.push(cur);
			console.log("D: " + tsN + "/" + tsD + " measure #" +
			    no + " (phys) at tick " + cur.tick +
			    " length " + ticksM);
			++no;
			cursor.nextMeasure();
		}
		map["list"] = mlist;
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

	/** signature: applyToNamedScore(score, cb, ...args) */
	function applyToNamedScore(theScore, cb) {
		var args = Array.prototype.slice.call(arguments, 2);
		var cursor = theScore.newCursor();
		args.unshift(cursor);
		var staveEnd = theScore.nstaves - 1;
		var rv = 0;

		for (var stave = 0; stave <= staveEnd; ++stave) {
			for (var voice = 0; voice < 4; ++voice) {
				cursor.staffIdx = stave;
				cursor.voice = voice;
				cursor.rewind(Cursor.SCORE_START);
				/*XXX https://musescore.org/en/node/301846 */
				cursor.staffIdx = stave;
				cursor.voice = voice;

				while (cursor.segment) {
					if (cursor.element)
						rv |= cb.apply(this, args);
					cursor.next();
				}
			}
		}
		return (rv);
	}

	function dropStaveText(cursor, measureMap) {
		if (cursor.element.type !== Element.CHORD)
			return;

		if (!cursor.segment.annotations)
			return;
		var nann = cursor.segment.annotations.length;
		while (nann--) {
			var ann = cursor.segment.annotations[nann];
			if (ann.type === Element.STAFF_TEXT) {
				console.log("D: " + showPos(cursor, measureMap) +
				    ": removing staff text: " + ann.text);
				removeElement(ann);
			}
		}
	}

	function labelBeat(cursor, measureMap, doneMap) {
		//console.log("D: " + showPos(cursor, measureMap) + ": " +
		//    nameElementType(cursor.element.type));
		if (cursor.element.type !== Element.CHORD)
			return;

		var t = cursor.segment.tick;
		if (doneMap[t])
			return;

		var m = measureMap[cursor.measure.firstSegment.tick];
		var text = "?";
		if (m && t >= m.tick && t < m.past) {
			var b = 1 + (t - m.tick) / m.ticksB;
			text = "" + b;
		}
		if (text == "" || text == "?")
			return;
		text = "a\u0084" + m.no + "\u0084" + text + "\u0084w";

		var elt = newElement(Element.STAFF_TEXT);
		elt.text = text;
		cursor.add(elt);
		doneMap[t] = true;
	}

	function analyseBeat(cursor, analyseMap) {
		if (cursor.element.type !== Element.CHORD)
			return;

		if (!cursor.segment.annotations)
			return;
		var nann = cursor.segment.annotations.length;
		while (nann--) {
			var ann = cursor.segment.annotations[nann];
			if (ann.type !== Element.STAFF_TEXT)
				continue;
			var a = ("" + ann.text).split("\u0084");
			if (a.length != 4 || a[0] != "a" || a[3] != "w") {
				console.log("W: weird ann: " + ann.text +
				    " :: " + JSON.stringify(a));
				continue;
			}
			var r = [parseInt(a[1]), parseFloat(a[2])];
			if (cursor.time in analyseMap) {
				var d = analyseMap[cursor.time];
				if (d[0] === r[0] && d[1] === r[1])
					continue;
				console.log("E: dup (" + r[0] + ", " + r[1] +
				    ") at " + cursor.time + ": (" + d[0] +
				    ", " + d[1] + ")");
				return (1);
			}
			analyseMap[cursor.time] = r;
		}
		return (0);
	}

	onRun: {
		console.log("I: requesting export path");
		fileDialogue.open();
	}

	function analyseScore() {
		var origScore = curScore;
		var origMeta = origScore.metaTag("platform");
		var newScore, newMeta;
		origScore.startCmd();

		var measureMap = buildMeasureMap(origScore);
		var doneMap = {};
		var analyseMap = {};
		applyToNamedScore(origScore, dropStaveText, measureMap);
		applyToNamedScore(origScore, labelBeat, measureMap, doneMap);

		cmd("unroll-repeats");
		newScore = curScore;
		newScore.startCmd();
		var abr = applyToNamedScore(newScore, analyseBeat,
		    analyseMap /*, buildMeasureMap(newScore) */);

		/* close unrolled version and switch back to origScore */
		newScore.endCmd(true);
		cmd("file-close");
		while (true) {
			newScore = curScore;
			if (newScore.scoreName == origScore.scoreName &&
			    newScore.metaTag("platform") == origMeta) {
				origScore.setMetaTag("platform", origMeta + "x");
				newMeta = newScore.metaTag("platform");
				origScore.setMetaTag("platform", origMeta);
				if (newMeta === origMeta + "x")
					break;
			}
			cmd("next-score");
		}
		/* rollback changes */
		origScore.endCmd(true);

		/* aborting from prior error? */
		if (abr)
			return;

		var analyseTimes = Array.prototype.map.call(Object.keys(analyseMap),
		    parseFloat);
		analyseTimes.sort(function fltSort(a, b) {
			return (a - b);
		});
		var z = analyseTimes.length;
		var n, t, d, lt = -1, tt, tr;
		var rt = [];
		for (n = 0; n < z; ++n) {
			t = analyseTimes[n];
			tt = Math.trunc(t);
			d = analyseMap[t];
			if (!d || !(tt >= lt)) {
				console.log("E: analyseMap[t] bad or empty: " + d);
				console.log("N: " + JSON.stringify({
					"n": n, "t": t, "tt": tt, "lt": lt,
				}));
				console.log("N: analyseMap=" + JSON.stringify(analyseMap));
				console.log("N: analyseTimes=" + JSON.stringify(analyseTimes));
				return;
			}
			tr = [(tt > lt ? tt : t) / 1000.0, d[0], d[1]];
			lt = tt;
			rt.push(tr);
		}

		var measureList = measureMap["list"].map(function (cur) {
			return ([cur.tsN, cur.tsD]);
		});

		var result = {
			"measures": measureList,
			"time-positions": rt,
		};

		outfile.source = ("" + fileDialogue.fileUrl).slice(7) +
		    "/" + origScore.scoreName + ".locinfo.jsn";
		outfile.write(JSON.stringify(result) + "\n");
		console.log("I: written to " + outfile.source);
		resultBox.icon = StandardIcon.Information;
		resultBox.text = "Written to " + outfile.source;
	}
}
