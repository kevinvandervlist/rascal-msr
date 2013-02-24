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

module vis::Classes

import Datatypes;
import IO;
import List;
import analysis::CloneClasses;
import util::Editors;
import util::Files;
import vis::Figure;
import vis::KeySym;
import vis::Render;

private list[loc] files;
private Figure fig;
private Figure ccfig;
private str dupLines;
private str message = "";

public void visualizeCloneClasses(list[CC] cloneClasses) {
  setHighlightColors([color("yellow"), color("black")]);
  ccfig = classes(cloneClasses);
  fig = ccfig;

  render(computeFigure(Figure() { return fig; }));
} 

private Color(&T <: num) cscale(list[CC] ccs) =
  colorScale(
    [size(cc.fragments) | cc <- ccs],
    color("green"),
    color("red")
  );

private Figure classes(list[CC] cloneClasses) =
  vcat([
    text("Clone Classes", fontSize(20)),
    hcat([
      vcat([dups(cloneClasses[0].fragments[0]), messageBox()]),
      pack(
        [ class(cloneClasses, cc) | cc <- cloneClasses ],
        std(gap(2))
      )
    ])
  ], std(top()), std(left()));

private Figure class(list[CC] cloneClasses, CC cc) =
  box(
    width(size(head(cc.fragments).lines) * 2),
    aspectRatio(1),
    fillColor(cscale(cloneClasses)(size(cc.fragments))),
    classLink(cc),
    onMouseEnter(void() {
      message = "<size(head(cc.fragments).lines)> lines\n" +
           "<size(cc.fragments)> clones";
      dupLines = toStr(head(cc.fragments)); 
    })
  );

private Figure cloneclass(CC cc) =
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

private Figure dupsFile(file, cc) =
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

private Figure dups() =
  scrollable(text(str() { return dupLines; }, font("Monospaced")), size(400, 400), resizable(false));

private Figure dups(CF cf) {
  dupLines = toStr(cf);
  return dups();
}

private Figure messageBox() =
  text(str() { return message; }, width(400), resizable(false));

private FProperty classLink(CC cc) =
  onMouseDown(bool(int butnr, map[KeyModifier, bool] modifiers) {
    fig = cloneclass(cc);
    return true;
  });

private FProperty editor(loc file, CC cc) =
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
