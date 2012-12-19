module advtrack::vis::Classes

import IO;
import List;
import vis::Figure;
import vis::Render;

import advtrack::Datatypes;
import advtrack::kevin::Detection::Dups;
import advtrack::tests::testGenerator;


public void main() {
    files = |file:///home/jimi/Downloads/HelloWorldGitDemo/src/demo|.ls;
    ccs = getCloneClasses(files);
    
    fig = classes(ccs);
    render(fig);

/*
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
*/
}

public Figure classes(list[CC] ccs) {
    cscale = colorScale(
        [size(cc.fragments) | cc <- ccs],
        color("green"),
        color("red")
    );

    return pack(
        [
            box(
                size(
                    size(head(cc.fragments)) * 5,
                    size(head(cc.fragments)) * 5
                ),
                fillColor(cscale(size(cc.fragments))),
                popup(
                    "<size(head(cc.fragments))> lines\n" +
                    "<size(cc.fragments)> clones"
                )
            ) |
            cc <- ccs
        ],
        std(gap(2))
    );
}

public FProperty popup(str S) =
    mouseOver(
        box(text(S), fillColor("lightyellow"), grow(1.2), resizable(false))
    );
