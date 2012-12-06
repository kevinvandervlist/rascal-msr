module advtrack::tests::testGenerator

//import advtrack::tests::lipsum;
import advtrack::Datatypes;
import Map;

//TODO: Jimi
//CCCloneSections generateCCCS(){
//}


bool contains(list[CF] unique, CF frag){
	for(ufrag <- unique){
		if(isIdenticalCF(ufrag, frag)){
			return true;
		}
	}
	
	return false;
}


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

 