module advtrack::vis::Classes

import IO;
import List;
import vis::Figure;
import vis::Render;

import advtrack::Datatypes;
import advtrack::kevin::Dups;
import advtrack::tests::testGenerator;


public void main() {
    files = |file:///D:/Documenten/UvA/Architecture/HelloWorldGitDemo/src/demo|.ls;
    ccs = getCloneClasses(files);

	render(
		hcat([
			outline(
				[
					highlight(
						l@linelocation.line,
						l.line,
						indexOf(ccs, getCC(cf, ccs))
					) |
					cf <- CFsWithLoc(file, ccs),
					l <- cf.lines
				],
				size(readFileLines(file)),
				size(20, size(readFileLines(file)))
			) |
			file <- files
		])
	);
}