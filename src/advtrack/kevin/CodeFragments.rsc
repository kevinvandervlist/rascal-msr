module advtrack::kevin::CodeFragments

import List;
import Set;

import advtrack::Datatypes;

public list[CF] createCodeFragments(list[codeline] cl) {
	// Step one:
	//cflist = createInitialCFList(cl);
}

private list[CF] createInitialCFList(list[codeline] cl) {
	//location(loc file, int line);
	//codeline(str line, location linelocation);
	//CF(loc file, list[codeline] lines);
	
	list[codeline] buf = [];
	list[CF] ret = [];

	prevcl = head(cl);
	int block_size = 0;

	for(c <- cl) {
		// Same file, in block threshold?
		if(	(x.l.file == prev.file) &&
			((prev.line + gap) >= x.l.line)) {
			block_size += 1;
			buf += x;
		} else {
			// Different file, reset counter stuff and possibly add to ret
			if((buf != {}) && (block_size >= block)) {
				ret += sort(buf);
			}
			block_size = 0;
			buf = {x};
		}
		// Set the previous location.
		prev = x.l;
	}
	return ret;
}