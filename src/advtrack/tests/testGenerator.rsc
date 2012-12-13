module advtrack::tests::testGenerator

import advtrack::Constants;
import advtrack::Datatypes;
import advtrack::tests::lipsum;
import advtrack::util::random;

import IO;
import List;
import Map;


import util::ValueUI;


public loc tmpFile = |tmp:///rascal/advtrack/testFile|;


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
    last(cf.lines) @ linelocation.line - head(cf.lines) @ linelocation.line + 1;

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
        if(i < size(blocks) - 1)
            currGap = head(blocks[i + 1].lines) @ linelocation.line -
                last(b.lines) @ linelocation.line - 1;

        newBlocks += moveCodeblock(b, n + offset);
        offset += randInt(1, GAP_SIZE) - currGap;
    }
    return newBlocks;
}


/**
given a list of code blocks belonging to a single clone fragment,
translate each block, such that its minimum offset is at least n greater than end
of last line of previous. Also add random gaps to given blocks.  
*
public list[codeblock] moveCodeblocksGapped2(list[codeblock] blocks, int n) {
    //get last line of last code block
    int lastine = last(last(blocks).lines) @ linelocation.line + 1;
    int linecount = lastline - head(head(blocks).lines) @ linelocation.line;
    
    //start of next fragment is at least GAP_SIZE+1 lines after end of last fragment
    int translateFragment = linecount + GAP_SIZE + randInt(1, 5);
 
    //make sure all new fragments'  blocks are at least GAP_SIZE+1 lines 
    //away from their last position
    translatedBlocks = moveCodeBlocks(blocks, translateFragment);
    
    //the offset wil be used to count the number of new lines of gaps introduced/removed
    /offset must always be between [0, GAP_SIZE]
    int offset = 0;
    
    previousBlock = null;
    
    for(currentBlock <- blocks){
            int gap = randInt(0, GAP_SIZE);
            int currentGap = 0;
            
            if(previousBlock != null){
                currentGap = head(currentBlock.lines) @ linelocation.line - 
                                    last(previousBlock.lines) @ linelocation.line; 
            }
            
            int newGap = gap - currentGap;
            offset += newGap;
    }
}*/


public list[codeblock] splitCodeblock(codeblock b, int pos, int gap) =
    [
        codeblock(take(pos, b.lines), b.begin),
        moveCodeblock(codeblock(drop(pos, b.lines), b.begin + pos), gap)
    ];

public list[codeblock] randSplitCodeblock(codeblock b) =
    splitCodeblock(b, randInt(1, size(b.lines) - 2), randInt(0, GAP_SIZE));

public list[codeblock] splitCodeblocks(list[codeblock] cbs, int pos, int gap) {
    largest = indexOf(cbs, largestCodeblock(cbs));
    splitted = splitCodeblock(cbs[largest], pos, gap);
    cbs[largest] = splitted[0];
    cbs = insertAt(cbs, largest + 1, splitted[1]);
    return cbs;
}

public codeblock largestCodeblock(list[codeblock] cbs) =
    sort(cbs, bool(codeblock b1, codeblock b2){ return size(b1.lines) > size(b2.lines); })[0];


public CCCloneSections generateCCCS() {
    cccs = [];
    lipsumSize = randInt(6, 10);
    orig = [toCodeblock(getLipsum(lipsumSize), tmpFile, 0)];
    copy = [moveCodeblock(head(orig), randInt(BLOCK_SIZE, 12) + lipsumSize)];

    for(i <- [0 .. 3]) {
        cfx = toCF(orig);
        cfy = toCF(copy);
        assert size(cfx) + size(cfy) + 6 <= last(cfy.lines) @ linelocation.line - head(cfx.lines) @ linelocation.line + 1;
        
        csxy = CSxy({ CS(orig[j], copy[j]) | j <- [0 .. size(orig) - 1] });
        cfxy = CFxy(cfx, cfy);
        cccs += CFxyCSxy(cfxy, csxy);

        splitAt = randInt(1, size(largestCodeblock(copy).lines) - 1);
        orig = splitCodeblocks(copy, splitAt, 0);
        copy = moveCodeblocksGapped(orig, randInt(BLOCK_SIZE, 12) + size(cfy));
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
	
	//text(unique);
	cc = CC(unique);
	generateFiles(cc);
	return cc;
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
			result += getNextNoise(linesofnoise-1);
		
		result +=  clonedline.line;
		currentlinenumber = clonedlinenumber;
	}
	
	result += getNextNoise(randInt(0, 10));
	
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

 