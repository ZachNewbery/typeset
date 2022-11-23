#############################################################################
##
#M  GenLatexTmpl( <digraph> ) . 
##  
## produces a template LaTeX string representing the structure of the provided digraph.
##
InstallMethod(GenLatexTmpl, "for directed graphs", true,
[ IsDigraph ], 0,
function( obj )
	return "\\begin{{center}}\n\\begin{{tikzpicture}}[>=latex',line join=bevel,]\n{}\n\\end{{tikzpicture}}\n\\end{{center}}";
end);

#############################################################################
##
#M  GenArgs( <digraph> ) . 
##  
## produces a list of strings representing the semantics of the provided digraph.
## used to populate the template string.
##
InstallMethod(GenArgs, "directed graphs", true,
[ IsDigraph ], 0,
function ( obj )
	local opts, ret, dot;
	opts := ValueOption("options");
	ret := "";

	if opts.("DigraphOut")="dot2tex" then
		Append(ret, Dot2Tex(obj));
	else
		# Simply makes use of the dot2texi LaTeX package to allow raw DOT to be input
		# and converted during LaTeX compilation.
		Info(InfoLatexgen, 2, "To use the dot2tex environment, add the dot2texi package to your premable \\usepackage{dot2texi}");
		dot := DotDigraph(obj);
		Append(ret, "\\begin{dot2tex}[dot,tikz,codeonly,styleonly,options=-s -tmath]\n");
		Append(ret, dot{[7..Length(dot)-1]});
		Append(ret, "\n\\end{dot2tex}");
	fi;

	return [ ret ];
end);

#############################################################################
##
#M  Dot2Tex( <digraph> ) . 
##  
## produces a list of strings representing the semantics of the provided digraph.
## used to populate the template string.
##
InstallMethod(Dot2Tex, "directed graphs", true,
[ IsDigraph ], 0,
function ( obj )
	local dot, inp, ret, out, dir, f;
	dot := DotDigraph(obj);
	inp := InputTextString(dot);

	# Construct temporary vars to pass as arguments to Process.
	dir := DirectoryTemporary();
    f := Filename(DirectoriesSystemPrograms(), "dot2tex");

	# Prefix to put figure in tikzpicture.
	ret := "  ";
	out := OutputTextString(ret, true);

	# Call dot2tex on preprocessed dot string. --codeonly allows removal of empty comments.
	Process(dir, f, inp, out, ["--usepdflatex", "--autosize", "--figonly", "--codeonly", "--format=tikz"]);

	# Remove empty comment lines.
	ret := ReplacedString(ret{[1..Length(ret)-3]}, "%%\n", "");
	return ret;
end);