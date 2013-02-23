module analysis::Sections


import Datatypes;
import List;
import Set;

// return clone sections created from a single clone class
public CCCloneSections getCCCloneSections(CC class) {
	assert (size(class.fragments) > 0);
	
	int s = size(class.fragments) - 1;
  
  return [ 
    x | 
    i <- [0..s], 
    j <- [0..s], 
    i != j, 
    cur := CFxy(class.fragments[i], class.fragments[j]), 
    x := CFxyCSxy(cur, getSections(cur))
  ]; 
}

private CSxy getSections(CFxy current) {
  set[CS] sections = {};
	
  int s = size(current.x.lines);
  bool restart = true;
  codeblock a = codeblock([], 0);
  codeblock b = codeblock([], 0);
  
  int i = 0;
  while (i < s) {
    if (restart) {
      if (!isEmpty(a.lines))
        sections += {CS(a, b)};
      a = codeblock([current.x.lines[i]], current.x.lines[i]@linelocation.line);
      b = codeblock([current.y.lines[i]], current.y.lines[i]@linelocation.line);
      restart = false;
    } else {
      if (current.x.lines[i]@linelocation.line == current.x.lines[i-1]@linelocation.line + 1 &&
         current.y.lines[i]@linelocation.line == current.y.lines[i-1]@linelocation.line + 1) {
        a.lines += [current.x.lines[i]];
        b.lines += [current.y.lines[i]];
      } else {
        i -= 1;
        restart = true;
      }    
    }
    i += 1;
  }
  
  if(!isEmpty(a.lines))
    sections += {CS(a, b)};
  
  return CSxy(sections);
}
