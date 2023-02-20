/*-
 * Copyright © 2021
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
 * Show ticks of selection, to aid in debugging some messages such as
 * “in measure underrun”.
 */

import MuseScore 3.0
import QtQuick 2.0
import QtQuick.Dialogs 1.2

MuseScore {
	description: "This mu͒3 plugin shows the ticks of the current selection";
	requiresScore: true;
	version: "3";
	menuPath: "Plugins.Show ticks";

	id: showTicks
	Component.onCompleted: {
		if (mscoreMajorVersion >= 4) {
			showTicks.title = "Show ticks";
		}
	}

	MessageDialog {
		id: alert;
		title: "Ticks position in score";
		icon: StandardIcon.Information;
	}

	onRun: {
		var minpos = 2147483647;
		var maxpos = 0;
		var seen = 0;
		var end = "";

		if (curScore.selection && curScore.selection.elements &&
		    curScore.selection.elements.length) {
			var elts = curScore.selection.elements;
			console.log("operating on selection: " + elts.length);
			for (var idx = 0; idx < elts.length; ++idx) {
				var e = elts[idx];
				while (e) {
					if (e.type == Element.SCORE) {
						console.log("child of score");
					} else if (e.type == Element.PAGE) {
						console.log("child of page");
					} else if (e.type == Element.SYSTEM) {
						console.log("child of system");
					} else if (e.type == Element.MEASURE) {
						console.log("child of measure");
					} else if (e.type != Element.SEGMENT) {
						e = e.parent;
						continue;
					}
					break;
				}
				if (!e || e.type != Element.SEGMENT) {
					console.log("#" + idx + " skipped, " +
					    "no segment as parent");
					continue;
				}
				console.log("#" + idx + " at " + e.tick);
				if (e.tick < seen) {
					console.log("below " + seen + ", ignoring");
					continue;
				}
				seen = e.tick ? 1 : 0;
				if (e.tick < minpos)
					minpos = e.tick;
				if (e.tick > maxpos)
					maxpos = e.tick;
			}
		}

		var cursor = curScore.newCursor();
		cursor.rewind(Cursor.SELECTION_START);
		if (cursor.segment) {
			console.log("operating on cursor at " + cursor.tick);
			seen = cursor.tick ? 1 : 0;
			if (cursor.tick < minpos)
				minpos = cursor.tick;
			if (cursor.tick > maxpos)
				maxpos = cursor.tick;
			cursor.rewind(Cursor.SELECTION_END);
			if (!cursor.tick) {
				/* until end of the score */
				cursor.rewind(Cursor.SELECTION_START);
				while (cursor.next())
					/* nothing */;
				end = " (end of score)";
				console.log("EOS at " + cursor.tick);
			} else
				console.log("cursor until " + cursor.tick);
			var csrmax = cursor.tick - 1;
			if (csrmax > seen) {
				if (csrmax < minpos)
					minpos = csrmax;
				if (csrmax > maxpos)
					maxpos = csrmax;
			}
		}

		if (minpos == 2147483647)
			alert.text = "could not find position";
		else if (maxpos <= minpos)
			alert.text = "at " + minpos + end;
		else
			alert.text = "from " + minpos + " to " + maxpos + end;
		alert.open();
	}
}
