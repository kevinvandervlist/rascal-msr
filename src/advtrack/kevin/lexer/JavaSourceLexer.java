package advtrack.kevin.lexer;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.antlr.runtime.*;
import org.eclipse.imp.pdb.facts.*;

import advtrack.kevin.lexer.antlr.*;

public class JavaSourceLexer {
	private final IValueFactory valueFactory;
	
	public JavaSourceLexer(IValueFactory valueFactory) {
		this.valueFactory = valueFactory;
	}
	
	public IValue lexJavaFile(ISourceLocation sloc) {
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

			while(it.hasNext()) {
				String st = it.next();
				st = st.replaceFirst("^[ \t]*", "").replaceFirst("[ \t]*$", "");
				IString cur = this.valueFactory.string(st);
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
        	buf.append(" ");
        	
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
       	/*if(token.getType() == JavaLexer.IDENTIFIER) {
       		// Parameter replacement:
       		return "$p";
       	} else*/ if(token.getType() == JavaLexer.PACKAGE) {
       		// RJ1: remove package names
       		return "";
       	} else if (	(token.getType() == JavaLexer.PUBLIC) ||
       				(token.getType() == JavaLexer.PROTECTED) ||
       				(token.getType() == JavaLexer.PRIVATE)) {
       		return "";
       		// RJ2: remove accessibility keyword
		} else if(	(token.getType() == JavaLexer.COMMENT) ||
					(token.getType() == JavaLexer.LINE_COMMENT)) {
			return "";
		}else {
       		// Other cases
			return token.getText();
       	}
	}
}