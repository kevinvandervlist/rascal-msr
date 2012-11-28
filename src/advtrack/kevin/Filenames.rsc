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
