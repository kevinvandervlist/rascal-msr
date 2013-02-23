module advtrack::vis::Classes

import IO;
import List;
import util::Editors;
import vis::Figure;
import vis::KeySym;
import vis::Render;

//import resource::versions::Versions;
//import resource::versions::git::Git;

import advtrack::Datatypes;
import advtrack::kevin::Detection::Dups;
import advtrack::kevin::Filenames;
//import advtrack::kevin::Git;
import advtrack::tests::testGenerator;


private list[loc] files;
private list[CC] ccs;
private Figure fig;
private Figure ccfig;
private str dupLines;
private str message = "";


public void main() {
    //str gitLoc  = "/home/jimi/CodeFabriek/ThirdSight/WebSight/app/";
    str gitLoc = "/home/kevin/src/QL-R-kemi/src/";
    
    con = fs(gitLoc);
    
    // Reverse so the oldest revision will be on top
    set[LogOption] opt = {reverse()};
    
    // Create a 'Repository' datatype of the git Connection
    repo = git(con, "", opt);
    
    // Get a list of files:
    m = cunit(branch("master"));
    fileList = getFilesFromCheckoutUnit(m, repo);
    
    // Filter file extensions
    files = getByFileExtension(".rsc", fileList);
    iprintln(files);
    
    
    ccs = getCloneClasses(files);

    setHighlightColors([color("yellow"), color("black")]);

    ccfig = classes();
    fig = ccfig;
    render(computeFigure(Figure() { return fig; }));
}

public void visualizeCloneClasses(list[CC] cloneClasses) {
  ccs = cloneClasses;

  setHighlightColors([color("yellow"), color("black")]);
  ccfig = classes();
  fig = ccfig;

  render(computeFigure(Figure() { return fig; }));
} 

public Color(&T <: num) cscale(list[CC] ccs) =
    colorScale(
        [size(cc.fragments) | cc <- ccs],
        color("green"),
        color("red")
    );

public Figure classes() =
    vcat([
        text("Clone Classes", fontSize(20)),
        hcat([
            vcat([dups(ccs[0].fragments[0]), messageBox()]),
            pack(
                [ class(cc) | cc <- ccs ],
                std(gap(2))
            )
        ])
    ], std(top()), std(left()));

public Figure class(CC cc) =
    box(
        width(size(head(cc.fragments).lines) * 2),
        aspectRatio(1),
        fillColor(cscale(ccs)(size(cc.fragments))),
        classLink(cc),
        onMouseEnter(void() {
            message = "<size(head(cc.fragments).lines)> lines\n" +
                      "<size(cc.fragments)> clones";
            dupLines = toStr(head(cc.fragments)); 
        })
    );

public Figure cloneclass(CC cc) =
    vcat([
        button(
            "Back",
            void() {
                fig = ccfig;
                
                // For some reason, need to re-render
                render(computeFigure(Figure() { return fig; })); 
            },
            height(20)
        ),
        text(head(cc.fragments).file.path),
        hcat([
            dups(head(cc.fragments)),
            hcat([dupsFile(file, cc) | file <- files, hasFragments(file, cc)])
        ])
    ], std(top()), std(left()), std(resizable(false)), std(gap(5)));

public Figure dupsFile(file, cc) =
    vcat([
        outline(
            [
                highlight(
                    l@linelocation.line,
                    l.line,
                    1
                ) |
                cf <- cc.fragments,
                cf.file == file,
                l <- cf.lines
            ],
            size(readFileLines(file)),
            size(20, size(readFileLines(file))),
            editor(file, cc)
        ),
        text(file.path, textAngle(91))
    ]);

public Figure dups() =
    scrollable(text(str() { return dupLines; }, font("Monospaced")), size(400, 400), resizable(false));

public Figure dups(CF cf) {
    dupLines = toStr(cf);
    return dups();
}

public Figure messageBox() =
    text(str() { return message; }, width(400), resizable(false));

public FProperty classLink(CC cc) =
    onMouseDown(bool(int butnr, map[KeyModifier, bool] modifiers) {
        fig = cloneclass(cc);
        return true;
    });

public FProperty editor(loc file, CC cc) =
    onMouseDown(bool(int butnr, map[KeyModifier, bool] modifiers) {
        loc file = file(0, 1, <1, 0>, <1, 0>);
        
        // Somehow need to re-render...
        render(computeFigure(Figure() { return fig; }));
        
        edit(
            file,
            [
                highlight(l @ linelocation.line + 1, "Duplicated"),
                warning(l @ linelocation.line + 1, "Duplicated") |
                cf <- cc.fragments,
                cf.file.uri == file.uri,
                l <- cf.lines
            ]
        );
        return true;
    });
