module advtrack::tests::testGenerator

import advtrack::Constants;
import advtrack::Datatypes;
import advtrack::tests::lipsum;
import advtrack::util::random;

import IO;
import List;
import Map;

import util::ValueUI;


private loc tmpFile = |tmp:///rascal/advtrack/testFile|;


public codeline toCodeline(str line, loc file, int linenumber) =
    codeline(line)[@linelocation = location(file, linenumber)];

public list[codeline] toCodelines(list[str] lines, loc file, int startline) =
    [toCodeline(lines[i], file, startline + i) | i <- index(lines)];

public codeblock toCodeblock(list[str] lines, loc file, int startline) =
    codeblock(toCodelines(lines, file, startline), startline);

public CF toCF(codeblock cb) =
    CF(cb.lines[0] @ linelocation.file, cb.lines);

public CF toCF(list[codeblock] cbs) =
    CF(cbs[0].lines[0] @ linelocation.file, [l | cb <- cbs, l <- cb.lines]);

public int size(CF cf) =
    last(cf.lines) @ linelocation.line - head(cf.lines) @ linelocation.line;

public codeblock moveCodeblock(codeblock b, int n) =
    codeblock(
        [ x |
            l <- b.lines,
            x := codeline(l.line)[
                @linelocation = location(
                    l @ linelocation.file,
                    l @ linelocation.line + n
                )
            ]
        ],
        b.begin + n
    );

public list[codeblock] moveCodeblocks(list[codeblock] blocks, int n) =
    [moveCodeblock(b, n) | b <- blocks];

public list[codeblock] moveCodeblocksGapped(list[codeblock] blocks, int n) {
    newBlocks = [];
    offset = 0;
    for(i <- [0 .. size(blocks) - 1]) {
        b = blocks[i];
        currGap = 0;
        println(b);
        if(i > 0)
            currGap = head(b.lines) @ linelocation.line -
                last(blocks[i - 1].lines) @ linelocation.line;

        newBlocks += moveCodeblock(b, n + offset);
        offset += randInt(1, GAP_SIZE) - currGap;
    }
    return newBlocks;
}

public list[codeblock] splitCodeblock(codeblock b, int pos, int gap) =
    [
        codeblock(take(pos, b.lines), b.begin),
        moveCodeblock(codeblock(drop(pos, b.lines), b.begin + pos), gap)
    ];

public list[codeblock] randSplitCodeblock(codeblock b) =
    splitCodeblock(b, randInt(1, size(b.lines) - 2), randInt(0, GAP_SIZE));

public list[codeblock] splitCodeblocks(list[codeblock] cbs, int pos, int gap) {
    largest = largestCodeblock(cbs);
    return cbs - largest + splitCodeblock(largest, pos, gap);
}

public codeblock largestCodeblock(list[codeblock] cbs) =
    sort(cbs, bool(codeblock b1, codeblock b2){ return size(b1.lines) > size(b2.lines); })[0];


public CCCloneSections generateCCCS() {
    cccs = [];

    lipsumSize =6; //randInt(6, 10);
    orig = [toCodeblock(getLipsum(lipsumSize), tmpFile, 0)];
    copy = [moveCodeblock(head(orig), /*randInt(BLOCK_SIZE, 12)*/6 + lipsumSize)];

    for(i <- [0 .. 3]) {
        cfx = toCF(orig);
        cfy = toCF(copy);
        
        csxy = CSxy({ CS(orig[j], copy[j]) | j <- [0 .. size(orig) - 1] });
        cfxy = CFxy(cfx, cfy);
        cccs += CFxyCSxy(cfxy, csxy);

        splitAt = randInt(1, size(largestCodeblock(copy).lines) - 1);
        orig = splitCodeblocks(copy, splitAt, 0);
        copy = moveCodeblocksGapped(orig, /*randInt(BLOCK_SIZE, 12)*/6 + size(cfx));
    }

    //text(cccs);
    return cccs;
}


bool contains(list[CF] unique, CF frag){
	for(ufrag <- unique){
		if(isIdenticalCF(ufrag, frag)){
			return true;
		}
	}
	
	return false;
}


//TODO: Jimi
//CCCloneSections generateCCCS(){
//}


//TODO: Liam
CC generateCC(CCCloneSections cccs){
	
	//data CCCloneSections = CCCloneSections(map[CFxy fragments, CSxy sections] cccs);
	//data CC = CC(list[CF] fragments);
	//data CF = CF(loc file, list[codeline] lines);
	
	set[CFxy] pairs = domain(cccs); //get all CF fragment pairs
	list[CF] unique = [];
	
	for(pair <- pairs){
		if(!contains(unique, pair.x)){
			unique += pair.x;
		}
		
		if(!contains(unique, pair.y)){
			unique += pair.y;
		}
	}
	
	return CC(unique);
}


///TODO: Liam
void generateFile(CC cc){
	//output file
}

 