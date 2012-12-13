package advtrack.kevin.lexer;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

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
	
	public IValue lexFile(ISourceLocation sloc) {
		CharStream cs = null;
		List<String> list = null;
		
		try {
			cs = new ANTLRFileStream(sloc.getURI().getPath());
			
			JavaLexer lexer = new JavaLexer(cs);
			
			list = tokenizeSourceFile(lexer);
		} catch (IOException e) {
			System.err.println(e.getStackTrace());
		}
		
		if(list != null) {
			// Create a list to return to rascal 
			Iterator<String> it = list.iterator();
			
			IList retl = this.valueFactory.list();
			retl.append(this.valueFactory.string("WTF"));

			/*
			for(int i = 0; i < list.size(); i++) {
				retl.append(this.valueFactory.string(list.get(i)));
			}
			
			for(int i = 0; i < 10; i++) {
				retl.append(this.valueFactory.string(list.get(i)));
			}
			*/
			
			while(it.hasNext()) {
				IString cur = this.valueFactory.string(it.next());
				retl = retl.append(cur);
			}
			return retl;
		} else {
			return this.valueFactory.list();
		}
	}
	
	/**
	 * Based on a given lexer, parse a source file in such a way that
	 * all rewrite rules replace the needed tokens.
	 * @param lexer
	 * @return
	 */
	
	private List<String> tokenizeSourceFile(JavaLexer lexer) {
		CommonTokenStream tokens = new CommonTokenStream();
		List<String> lines = new ArrayList<String>();
		
        StringBuffer buf = new StringBuffer();
        int curline = 1;
        int prevline = 1;

		tokens.setTokenSource(lexer);
		
        Token token = lexer.nextToken();

        // Create a list of lines, where tokens correspond to the original source file.
        while(token.getType() != JavaLexer.EOF) {
        	int cl = token.getLine();
        	
        	if (cl == (prevline + 1) || curline != cl) {
        		lines.add(buf.toString());
        		if (curline != cl) {
        			int diff = cl - prevline - 1;
        			for(int i = 0; i < diff; i++) {
        				lines.add("");
        			}
        		}
        		buf = new StringBuffer();
        	}
        	
        	buf.append(applyRewriteRules(token));
        	
        	// Make sure to update the counters
        	curline = cl;
        	prevline = cl;
        	
        	token = lexer.nextToken();
        }
        
        lines.add(buf.toString());

        return lines;
	}
	
	/**
	 * Call the rewrit rules that are needed for the current token.
	 * @param token
	 * @return The string to rewrite the token to.
	 */
	
	private String applyRewriteRules(Token token) {
		return token.getText();
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