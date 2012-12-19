module advtrack::vis::Classes

import IO;
import List;
import util::Editors;
import vis::Figure;
import vis::KeySym;
import vis::Render;

import resource::versions::Versions;
import resource::versions::git::Git;

import advtrack::Datatypes;
import advtrack::kevin::Detection::Dups;
import advtrack::kevin::Filenames;
import advtrack::kevin::Git;
import advtrack::tests::testGenerator;


private list[loc] files;
private list[CC] ccs;
private Figure fig;


public void main() {
    str gitLoc  = "/home/jimi/Downloads/yapo/";

    con = fs(gitLoc);
    
    // Reverse so the oldest revision will be on top
    set[LogOption] opt = {reverse()};
    
    // Create a 'Repository' datatype of the git Connection
    repo = git(con, "", opt);
    
    // Get a list of files:
    m = cunit(branch("master"));
    fileList = getFilesFromCheckoutUnit(m, repo);
    
    // Filter file extensions
    files = getByFileExtension(".java", fileList);
    
    
    ccs = getCloneClasses(files);
    
    fig = classes();
    render(computeFigure(Figure() { return fig; }));
}

public Figure classes() {
    cscale = colorScale(
        [size(cc.fragments) | cc <- ccs],
        color("green"),
        color("red")
    );

    return pack(
        [
            box(
                size(
                    size(head(cc.fragments).lines) * 5,
                    size(head(cc.fragments).lines) * 5
                ),
                fillColor(cscale(size(cc.fragments))),
                popup(
                    "<size(head(cc.fragments).lines)> lines\n" +
                    "<size(cc.fragments)> clones"
                ),
                onMouseDown(bool (int butnr, map[KeyModifier, bool] modifiers) {
                    //println("AA");
                    fig = class(cc);
                    return true;
                })
            ) |
            cc <- ccs
        ],
        std(gap(2))
    );
}

public Figure class(CC cc) =
    vcat([
        button(
            "Back",
            void() { 
                fig = classes();
                render(computeFigure(Figure() { return fig; })); 
            },
            height(20)
        ),
        text(head(cc.fragments).file.path),
        hcat([
            hscrollable(text(toStr(head(cc.fragments)), font("Monospaced")), width(400)),
            hcat([
                vcat([
                    outline(
                        [
                            highlight(
                                l@linelocation.line,
                                l.line,
                                4
                            ) |
                            cf <- cc.fragments,
                            cf.file == file,
                            l <- cf.lines
                        ],
                        size(readFileLines(file)),
                        size(20, size(readFileLines(file))),
                        editor(file)
                    ),
                    text(file.path, textAngle(91))
                ]) |
                file <- files
            ])
        ])
    ], std(top()), std(left()), std(resizable(false)), std(gap(5)));

public FProperty popup(str S) =
    mouseOver(
        box(text(S), fillColor("lightyellow"), grow(1.2), resizable(false))
    );

public FProperty classLink(CC cc) =
    onMouseDown(bool(int butnr, map[KeyModifier, bool] modifiers) {
        fig = class(cc);
        return true;
    });

public FProperty editor(loc l) =
    onMouseDown(bool(int butnr, map[KeyModifier, bool] modifiers) {
        println("Edidsd");
        loc file = l(0, 0, <0, 0>, <8, 1>);
        println("File: <file>");
        edit(file, [warning(4, "Duplicated")]);
        return true;
    });


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