module advtrack::util::Files

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
