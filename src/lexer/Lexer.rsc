@license{
  Copyright (c) 2013 
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Jimi van der Woning - Jimi.vanderWoning@student.uva.nl}
@contributor{Kevin van der Vlist - kevin@kevinvandervlist.nl}
@contributor{Liam Blythe - liam.blythe@student.uva.nl}
@contributor{Vladimir Komsiyski - vkomsiyski@gmail.com}

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
