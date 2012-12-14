module advtrack::kevin::lexer::Lexer

import advtrack::kevin::Filenames;

import IO;

@javaClass{advtrack.kevin.lexer.JavaSourceLexer}
public java str lexJavaLine(str rawline);

@javaClass{advtrack.kevin.lexer.JavaSourceLexer}
public java list[str] lexJavaFile(loc file);


public str lexLine(str rawline) {
	return lexJavaLine(rawline);
}

public list[str] lexFile(loc file) {
	if(isFileType("java", file)) {
		return lexJavaFile(file);
	} else {
		return readFileLines(file); 
	}
}
