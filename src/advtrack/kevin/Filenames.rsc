module advtrack::kevin::Filenames

/**
 * Strip a given file extension from the list of files.
 * @param ext The extension to strip with.
 * @param files The list[loc] with files.
 * @return list[loc] A list of files without the given extension.
 */
public list[loc] stripFileExtension(str ext, list[loc] files) {
	return [ x | x <- files, /<ext>$/ !:= x.path];
}

/**
 * Get files by a given file extension from the list of files.
 * @param ext The extension to get
 * @param files The list[loc] with files.
 * @return list[loc] A list of files with the given extension.
 */

public list[loc] filterFilesByExtension(str ext, list[loc] files) {
	return [ x | x <- files, /<ext>$/ := x.path];
}