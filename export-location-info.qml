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
 * Generate score location information, correlate with audio timing
 * information, export as structured text file named the basename of
 * the score plus “.locinfo”.
 *
 * Makes use of some techniques demonstrated by the MuseScore example
 * plugins. No copyright is claimed for these or the API extracts.
 */

import MuseScore 3.0
import QtQuick 2.0
import QtQuick.Dialogs 1.2
import FileIO 3.0

MuseScore {
	description: "This mu͒3 plugin exports score location information.";
	requiresScore: true;
	version: "0";
	menuPath: "Plugins.Export location info";

	id: exportLocationInfo
	Component.onCompleted: {
		// runs once before console.log is ready
		if (mscoreMajorVersion >= 4) {
			countNoteBeats.title = "Export location info";
		}
	}

	FileIO {
		id: outfile
		onError: console.log("E: FileIO(" + outfile.source + "): " + msg)
	}

	FileDialog {
		id: fileDialog
		title: "Please choose where to save the locinfo file"
		folder: "file://" + outfile.tempPath()
		selectFolder: true
		onAccepted: {
			outfile.source = ("" + fileDialog.fileUrl + "/" +
			    curScore.scoreName + ".locinfo").slice(7);
			exportLocationInfo.analyseScore();
		}
		onRejected: {
			console.log("I: user cancelled");
		}
	}

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
			  //XXX-virtual measure for split-sameno
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

	/** signature: applyToNamedScore(score, cb, ...args) */
	function applyToNamedScore(theScore, cb) {
		var args = Array.prototype.slice.call(arguments, 2);
		var cursor = theScore.newCursor();
		var staveEnd = theScore.nstaves - 1;

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
						cb.apply(null,
						    [cursor].concat(args));
					cursor.next();
				}
			}
		}
	}

	function labelBeat(cursor, measureMap, doneMap) {
		//console.log(showPos(cursor, measureMap) + ": " +
		//    nameElementType(cursor.element.type));
		if (cursor.element.type !== Element.CHORD)
			return;

		var t = cursor.segment.tick;
		if (doneMap[t])
			return;
//XXX todo but the annotations are per segment?! test this
		doneMap[t] = true;
		var m = measureMap[cursor.measure.firstSegment.tick];
		var text = newElement(Element.STAFF_TEXT);
		if (m && t >= m.tick && t < m.past) {
			var b = 1 + (t - m.tick) / m.ticksB;
			text.text = "" + b;
		} else {
			text.text = "?";
		}

		if (text.text == "")
			return;
		text.text = "qqq\u0001" + cursor.staffIdx + "\u0001" +
		    cursor.voice + "\u0001" + m.no + "\u0001" + text.text +
		    "\u0001qzq";
		text.fontFace = "exportLocationInfo"; //XXX broken during unrolling
		cursor.add(text);
	}

	function analyseBeat(cursor, analyseList) {
		if (cursor.element.type !== Element.CHORD)
			return;
		var ann;
		var annn = cursor.segment.annotations.length;
		while (annn--) {
			ann = cursor.segment.annotations[annn];
			if (ann.type !== Element.STAFF_TEXT ||
			    ann.fontFace !== "exportLocationInfo")
				continue;
			var a = ("" + ann.text).split("\u0001");
			if (a[0] !== "qqq" || a.length != 6 ||
			    a[5] !== "qzq") {
				console.log("weird ann: " + ann.text);
				continue;
			}
			analyseList.push({
				"stave": parseInt(a[1]),
				"voice": parseInt(a[2]),
				"measure": parseInt(a[3]),
				"beat": parseFloat(a[4]),
				"time": cursor.time
			});
		}
	}

	function analyseScore() {
		var origScore = curScore;
		var origMeta = origScore.metaTag("platform");
		var newScore, newMeta;
		origScore.startCmd();

		var measureMap = buildMeasureMap(origScore);
		var doneMap = {};
		var analyseList = [];
		applyToNamedScore(origScore, labelBeat, measureMap, doneMap);

		cmd("unroll-repeats");
		newScore = curScore;
		applyToNamedScore(newScore, analyseBeat, analyseList /*, buildMeasureMap(newScore) */);

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
		origScore.endCmd(true);

		analyseList.sort(function compareAnalyseList(a, b) {
			if (a.time === b.time) {
				if (a.stave === b.stave) {
					if (a.voice === b.voice) {
						if (a.measure === b.measure)
							return (a.beat - b.beat);
						return (a.measure - b.measure);
					}
					return (a.voice - b.voice);
				}
				return (a.stave - b.stave);
			}
			return (a.time - b.time);
		});

		var maxH = Math.trunc(origScore.duration / 3600);
		maxH = maxH > 9 ? maxH : 10;
		maxH = (""+maxH).replace(/./, "0");
		var maxL = -(maxH.length);
		var outLen = analyseList.length;
		for (var i = 0; i < outLen; ++i) {
			var a = analyseList[i];
			var h, m, s, c;
			c = Math.trunc(a.time);
			s = Math.trunc(c / 1000);
			c = c % 1000;
			m = Math.trunc(s / 60);
			s = s % 60;
			h = Math.trunc(m / 60);
			m = m % 60;
			analyseList[i] = (maxH + m).slice(maxL) + ":" +
			    ("0" + m).slice(-2) + ":" +
			    ("0" + s).slice(-2) + "." +
			    ("00" + c).slice(-3) +
			    " stave " + a.stave + " voice " + a.voice +
			    " measure " + a.measure + " beat " + a.beat;
		}
		console.log("I: writing to " + outfile.source)
		outfile.write(analyseList.join("\n"));
	}

	onRun: {
		console.log("I: requesting export path");
		fileDialog.open();
	}
}
