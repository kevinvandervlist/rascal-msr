module advtrack::LOC::FileLOC


import IO;
import lang::java::jdt::Java;
import lang::java::jdt::JDT;
import lang::java::jdt::JavaADT;
import util::ValueUI;
import util::Math;
import Node;
import Set;
import List;

public tuple[loc file, int LOC] getFileLOC(loc file) {
	lines = {};
	
	x = createAstFromFile(file);
	
	visit(x) {
		case p: packageDeclaration(_, _): 
			lines += {p@location.begin.line, p@location.end.line};
			
		case i: importDeclaration(_, _, _): 
			lines += {i@location.begin.line, i@location.end.line};
		
		case c: typeDeclaration(_, _, str class, str name, _, _, _, _): 
			lines += {c@location.begin.line, c@location.end.line};

		case f: fieldDeclaration(_, _, t, _): 
			lines += {t@location.begin.line, t@location.end.line};
		
		case m: methodDeclaration(_, _, _, _, str name, _, _, some(body)): 
			lines += getUnitLines(m, name, body);
		
		case i: methodDeclaration(_, _, _, _, str name, _, _, none()): 
			lines += {i@location.begin.line, i@location.end.line};
	}
	
	return <file, toInt(size(lines))>;
}

private set[int] getUnitLines(AstNode method, str name, AstNode body) {
	lineset = {method@location.begin.line, method@location.end.line};
	
	// SIG fix:
	/*
	y = 0;
	for (x <- f) {
		if(/^\s*(\{|\})\s*$/ := x) {
			y+=1;
		}
	}
	*/
		
	visit(body) {
		case AstNode a:
			lineset += {a@location.begin.line, a@location.end.line};
	}
	return lineset;
}
