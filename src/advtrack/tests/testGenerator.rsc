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

public list[codeblock] splitCodeblock(codeblock b, int pos, int gap) =
    [
        codeblock(take(pos, b.lines), b.begin),
        moveCodeblock(codeblock(drop(pos, b.lines), b.begin + pos), gap)
    ];

public list[codeblock] randSplitCodeblock(codeblock b) =
    splitCodeblock(b, randInt(1, size(b.lines) - 1), randInt(1, GAP_SIZE));


public CCCloneSections generateCCCS() {
    cccs = [];
    orig = toCodeblock(getLipsum(randInt(6, 10)), tmpFile, 0);
    for(i <- [0 .. 1]) {
        copy = moveCodeblock(orig, randInt(BLOCK_SIZE, 12) + size(orig.lines));
        cfx = toCF(orig);
        cfy = toCF(copy);
        csxy = CSxy({CS(orig, copy)});
        cfxy = CFxy(cfx, cfy);
        cccs += CFxyCSxy(cfxy, csxy);
        orig = copy;
    }
    text(cccs);
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

 