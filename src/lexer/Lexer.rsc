module lexer::Lexer

import IO;
import util::Files;

@javaClass{lexer.JavaSourceLexer}
public java list[str] lexJavaFile(loc file);

@javaClass{lexer.CSourceLexer}
public java list[str] lexCFile(loc file);

public str lexLine(str rawline) {
	return lexJavaLine(rawline);
}

/**
 * Lex a given file, and return a list[str] containing the lexed lines at 
 * the original positions. If the extensions is recognized, the right lexer will be called. 
 * Otherwise, the file is just returned as-is
 */

public list[str] lexFile(loc file) {
	if(isFileType("java", file)) {
		return lexJavaFile(file);
	} else if(isFileType("c", file)) {
		return lexCFile(file);
	} else {
		return readFileLines(file); 
	}
}
