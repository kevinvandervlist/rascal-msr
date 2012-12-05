package advtrack.kevin.lexer;

import org.antlr.runtime.*;
import org.eclipse.imp.pdb.facts.*;

import advtrack.kevin.lexer.antlr.*;

public class Lexer {
	private final IValueFactory valueFactory;
	
	public Lexer(IValueFactory valueFactory) {
		this.valueFactory = valueFactory;
	}
	
	public IString lexLine(IString rawline) {
		return this.valueFactory.string(lexer(rawline.getValue()));
	}
	
	/**
	 * This function takes a string from a Java source file, and then
	 * lexes it according to the Java grammar.
	 * Extra steps like rewriting can be included.
	 * @param line A raw line from the source file being read. 
	 * @return String A string containing just the lexed symbols.
	 */
	
	public String lexer(String line) {
		CharStream cs = new ANTLRStringStream(line);
			
		JavaLexer lexer = new JavaLexer(cs);
			
		CommonTokenStream tokens = new CommonTokenStream();
		tokens.setTokenSource(lexer);
		
        StringBuffer buf = new StringBuffer();
        
        Token token = lexer.nextToken();
        
        while(token.getType() != JavaLexer.EOF) {
        	// TODO: RJ2
        	if(token.getType() == JavaLexer.IDENTIFIER) {
        		// Parameter replacement:
        		buf.append("$p ");
        	} else if(token.getType() == JavaLexer.PACKAGE) {
        		// RJ1: remove package names
        	} else if (	(token.getType() == JavaLexer.PUBLIC) ||
        				(token.getType() == JavaLexer.PROTECTED) ||
        				(token.getType() == JavaLexer.PRIVATE)) {
        		// RJ2: remove accessibility keyword
        	} else {
        		// Other cases
        		buf.append(token.getText());
        		buf.append("");
        	}
        	token = lexer.nextToken();
        }
        return buf.toString();
	}
}