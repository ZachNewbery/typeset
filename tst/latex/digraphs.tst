#@local g, g2, s
gap> START_TEST( "digraphs.tst" );

# Dot2Texi LaTeX Environment
gap> g := Digraph([[1, 2], [2, 1]]);;
gap> Typeset(g);
\begin{center}
\begin{tikzpicture}[>=latex',line join=bevel,]
\begin{dot2tex}[dot,tikz,codeonly,styleonly,options=-s -tmath]
digraph hgn{
node [shape=circle]
1
2
1 -> 1
1 -> 2
2 -> 2
2 -> 1
}
\end{dot2tex}
\end{tikzpicture}
\end{center}
gap> g2 := Digraph([[1, 2], [2, 3], [3, 4], [4, 2], [4, 1]]);;
gap> Typeset(g2);
\begin{center}
\begin{tikzpicture}[>=latex',line join=bevel,]
\begin{dot2tex}[dot,tikz,codeonly,styleonly,options=-s -tmath]
digraph hgn{
node [shape=circle]
1
2
3
4
5
1 -> 1
1 -> 2
2 -> 2
2 -> 3
3 -> 3
3 -> 4
4 -> 4
4 -> 2
5 -> 4
5 -> 1
}
\end{dot2tex}
\end{tikzpicture}
\end{center}

# Dot2Tex Command Line Invocation
# Due to dependence on display screen size used by dot2tex
# it is difficult to create a positive test case that works
# both locally and in the repo. Therefore, a simple check
# for a non-empty populated templated string should suffice.
gap> s := TypesetString(g : options:= rec(LDelim := "(", RDelim :=")", Lang := "latex", DigraphOut := "dot2tex", SubCallOpts := false));;
gap> s <> "\\begin{center}\n\\begin{tikzpicture}[>=latex',line join=bevel,]\n\n\\end{tikzpicture}\n\\end{center}";
true

# End Test
gap> STOP_TEST( "digraphs.tst" );