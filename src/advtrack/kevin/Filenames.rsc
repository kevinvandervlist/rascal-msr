module advtrack::kevin::Filenames

public bool isFileType(str ftype, loc file) {
	return /<ftype>$/ := file.path;
}

/**
 * Remove a given file with an extension from the list of files.
 * @param ext The extension to strip with.
 * @param files The list[loc] with files.
 * @return list[loc] A list of files without the given extension.
 */
public list[loc] removeByFileExtension(str ext, list[loc] files) {
	return [ x | x <- files, !isFileType(ext, x)];
}

/**
 * Get files by a given file extension from the list of files.
 * @param ext The extension to get
 * @param files The list[loc] with files.
 * @return list[loc] A list of files with the given extension.
 */

public list[loc] getFilesByExtension(str ext, list[loc] files) {
	return [ x | x <- files, isFileType(ext, x)];
}