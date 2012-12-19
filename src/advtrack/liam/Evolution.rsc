module advtrack::liam::Evolution

import advtrack::DataTypes;
import advtrack::Constants;
import advtrack::kevin::Levenstein;



private CSEvolutionClass DetermineCSEvolutionClass(CS cs){
	real nld = ComputeCSDistance(cs);
	
	if(nld >= NLDT_HIGH)
		return Consistent();
	
	if(nld <= NLDT_LOW)
		return Inconsistent();
		
	return Unknown();	
}

 
private real ComputeCSdistance(CS cs){
	string sx = CodeblockToString(cs.x);
	string sy = CodeblockToString(cs.y);
	
	return NLD(sx, sy);
}


private string CodeblockToString(codeblock b){
	string result = "";
	
	for(cl <- b.lines)
		result += cl.line + "\n";
	
	return result;
}







