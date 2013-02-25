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

module util::Files

import IO;

public list[loc] listFilesRecursively(loc path) {
  list[loc] ret = [];

  children = listEntries(path);
  
  for(c <- children) {
    if(isDirectory(path + c)) {
      ret += listFilesRecursively(path + c);
    } else {
      ret += path + c;
    }
  }
  
  return ret;
}

public bool isFileType(str ftype, loc file) =
  /<ftype>$/ := file.path;

public list[loc] removeByFileExtension(str ext, list[loc] files) =
  [ x | x <- files, !isFileType(ext, x)];
  
public list[loc] removeByFileExtension(list[str] exts, list[loc] files) =
  [*removeByFileExtension(x, files) | x <- exts];

public list[loc] getByFileExtension(str ext, list[loc] files) =
  [ x | x <- files, isFileType(ext, x)];

public list[loc] getByFileExtension(list[str] exts, list[loc] files) =
  [*getByFileExtension(x, files) | x <- exts];
