module advtrack::tests::testGenerator

import advtrack::Datatypes;
import advtrack::tests::lipsum;
import advtrack::util::random;

import List;
import Map;


private loc tmpFile = |tmp:///rascal/advtrack/testFile|;


public codeline toCodeline(str line, loc file, int linenumber) =
    codeline(line)[@linelocation = location(file, linenumber)];

public list[codeline] toCodelines(list[str] lines, loc file, int startline) =
    [toCodeline(lines[i], file, startline + i) | i <- index(lines)];

public codeblock toCodeblock(list[str] lines, loc file, int startline) =
    codeblock(toCodelines(lines, file, startline), startline);

public tuple[codeblock, codeblock] arbSplitCodeblock(codeblock block) {
    splitAt = randInt(1, size(codeblock - 1));
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

 