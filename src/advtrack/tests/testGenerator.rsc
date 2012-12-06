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


//TODO: Liam
public CC generateCC(CCCloneSections cccs){
	
	//set[CFxy] pairs = domain(cccs); //get all CF fragment pairs
	list[CFxy] pairs = [cfcs.cf | cfcs <- cccs];
	list[CF] unique = [];
	
	for(pair <- pairs){
		if(!contains(unique, pair.x)){
			unique += pair.x;
		}
		
		if(!contains(unique, pair.y)){
			unique += pair.y;
		}
	}
	
	text(unique);
	return CC(unique);
}


//----------- Writing Clone class to file -------------------

alias Files =  map[loc, list[codeline]];

Files sortFiles(Files files){
	bool (&T a, &T b) sortFunc = bool(codeline a, codeline b){ return a@linelocation.line <= b@linelocation.line; }; 
	return (key: sort(files[key], sortFunc) | key <- domain(files)); 
}

/** determine which files are covered by the clone fragments,
each fragment in that file adds its lines to it
**/
public Files getFiles(list[CF] fragments){
	Files files = ();
	
	//inventorize which files there are by looping through fragments,
	//add all encoutered codelines to the corresponding file
	for(frag <- fragments){
		files[frag.file] = (frag.file in files) ? 
								(files[frag.file] + frag.lines) : frag.lines;
	}
	
	return sortFiles(files);
}


/**
create the string lists that represent all the content in a file
content is filled with clone lines at the specified line numbers and padded with noise on other line numbers 
**/
public list[str] fillFileLines(list[codeline] clonedlines){
	list[str] result = [];
	int currentlinenumber = 0;
	
	for(clonedline <- clonedlines){
		int clonedlinenumber = clonedline@linelocation.line;
		
		int linesofnoise = clonedlinenumber - currentlinenumber;
		
		if(linesofnoise > 1)
			result += getNoise(linesofnoise-1);
		
		result +=  clonedline.line;
		currentlinenumber = clonedlinenumber;
	}
	
	result += getNoise(randInt(0, 10));
	
	return result;
}


/**
physical output to file
there seems to be a bug in rascal file writing that does not automatically add line breaks after each value,
even though the documentation says it does
**/
void outputToFile(loc file, list[str] lines){

	int writenr = 0;
	
	for(line <- lines){
	
		if(writenr == 0)
			writeFile(file, line, "\n");
		else	
			appendToFile(file, line, "\n");
			
		writenr += 1;
	}
}


public void generateFiles(CC cc){

	Files files =  getFiles(cc.fragments);
	
	keys = domain(files);
	for( key <- keys ){
		outputToFile(key, fillFileLines(files[key]));
	}
}

 