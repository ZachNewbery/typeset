#############################################################################
##
#V  Dot2TexDefaultOptions . 
##  
## 	List of default command-line options passed to dot2tex when converting dot snippets.
##
InstallValue(Dot2TexDefaultOptions,
	["--autosize", "--figonly", "--codeonly", "--format=tikz"]);

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

	if opts.("DigraphOut")<>fail and opts.("DigraphOut")="dot2tex" then
		Append(ret, Dot2Tex(obj));
	else
		# Simply makes use of the dot2texi LaTeX package to allow raw DOT to be input
		# and converted during LaTeX compilation.
		Info(InfoTypeset, 2, "To use the dot2tex LaTeX environment, add the dot2texi package to your premable \\usepackage{dot2texi}");
		dot := DotDigraph(obj);
		Append(ret, "\\begin{dot2tex}[dot,tikz,codeonly,styleonly]\n");

		# Remove prepended '\\dot' from string as it is not required.
		Append(ret, dot{[7..Length(dot)-1]});

		Append(ret, "\n\\end{dot2tex}");
	fi;

	return [ ret ];
end);

#############################################################################
##
#M  Dot2Tex( <digraph> ) . 
##  
## produces a list of strings representing the semantics of the provided digraph
## used to populate the template string, via dot2tex invocation.
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
	SetPrintFormattingStatus(out, false);

	# Call dot2tex on preprocessed dot string. --codeonly allows removal of empty comments.
	Info(InfoTypeset, 3, "Running dot2tex on provided dot string");
	Process(dir, f, inp, out, Dot2TexDefaultOptions);

	# Remove empty comment lines.
	ret := ReplacedString(ret{[1..Length(ret)-3]}, "%%\n", "");
	return ret;
end);