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
	println("File: <file>");
	if(isFileType("java", file)) {
		println("Java");
		return lexJavaFile(file);
	} else {
		println("Other");
		return readFileLines(file); 
	}
}
