#############################################################################
##
#M  Typeset( <object> ) . 
##  
## produces a typesettable string representing the provided object.
##
InstallMethod(Typeset, "for all objects", true,
[ IsObject ],0,
function( x, opts... )
	local options, defaults, name, val, string, old;

	if IsEmpty(opts) then
		if ValueOption("options") = fail then
			# Merge default options with user-passed optional parameters.
			defaults := rec(LDelim := "(", RDelim :=")", Lang := "latex", DigraphOut := "dot", SubCallOpts := false);
			options := rec();

			for name in RecNames(defaults) do
				if ValueOption(name) = fail then
					options.(name) := defaults.(name);
				else
					val := ValueOption(name);

					# Explicitly convert characters to strings for easier handling later.
					if IsChar(val) then
						val := [val];
					fi;

					options.(name) := val;
				fi;
			od;
		else
			# Handling where options struct has already been constructed.
			options := ValueOption("options");
		fi;
	elif Length(opts)>=1 then
		options := opts[1];
		if Length(opts) > 1 then
			# Throw error
			Error("More than one optional argument passed.");
		fi;
	fi;

	# Determine function to create output string (based on lang option).
	string := TypesetString(x : options := options);
	Add(string, '\n');

	# Print to terminal (use SetPrintFormattingStatus to remove line breaks).
	old := PrintFormattingStatus("*stdout*");
	SetPrintFormattingStatus("*stdout*", false);
	PrintFormattedString(string);
	SetPrintFormattingStatus("*stdout*", old);
end);

#############################################################################
##
#M  TypesetString( <object> ) . 
##  
## produces a typesetable string representing the provided object.
##
InstallMethod(TypesetString, "for all objects", true,
[ IsObject ],0,
function( x )
	local options, lang, t, string, args, tmpl;
	
	# Determine template string generation function.
	options := ValueOption("options");
	if options=fail then
		lang := "latex";
		options := rec(MatrixDelim := "[]", Lang := "latex", SubCallOpts := false);
	fi;

	lang := options.("Lang");
	lang[1] := UppercaseChar(lang[1]);
	t := EvalString(Concatenation("Gen", lang, "Tmpl"));

	# Generate and populate template string.
	tmpl := t(x : options := options);
	args := GenArgs(x : options := options);
	Add(args, tmpl, 1);
	string := CallFuncList(StringFormatted, args);
	return string;
end);

#############################################################################
##
#M  GenArgs( <object> ) . 
##  
## produces a list of objects representing the semantics of the provided object.
## used to populate the template string.
##
InstallMethod(GenArgs, "fallback default method", true,
[ IsObject ], 0, String);

InstallMethod(GenArgs, "rational", true,
[ IsRat ], 0,
function ( x )
	if IsInt(x) then
    	return [ String(x) ];
  	fi;
	return [ NumeratorRat(x), DenominatorRat(x) ];
end);

InstallMethod(GenArgs, "internal ffe", true,
[ IsFFE and IsInternalRep ], 0,
function ( ffe )
	local char, ret, deg, log;
	char := Characteristic(ffe);
	ret := [ char, "", "" ];
	if not IsZero(ffe) then
		deg := DegreeFFE(ffe);
		if deg <> 1  then
			ret[2] := Concatenation("^{", String(deg), "}");
		fi;

		log := LogFFE(ffe,Z( char ^ deg ));
		if log <> 1 then
			ret[3] := Concatenation("^{", String(log), "}");
		fi;
	fi;

	return ret;
end);

InstallMethod(GenArgs, "matrix", true,
[ IsMatrix ], 0,
function ( m )
	local i, j, l, n, r, subOptions;
	subOptions := MergeSubOptions(ValueOption("options"));

	l:=Length(m);
  	n:=Length(m[1]);
	r := [];

	for i in [1..l] do
		for j in [1..n] do
			Add(r, TypesetString(m[i][j] : options := subOptions));
		od;
	od;

	return r;
end);

InstallMethod(GenArgs, "polynomials", true,
[ IsPolynomial ], 0, 
function( poly )
	local i, j, fam, ext, zero, one, mone, c, le, r, subOptions;
	subOptions := MergeSubOptions(ValueOption("options"));

	r := [];
	fam := FamilyObj(poly);
	ext := ExtRepPolynomialRatFun(poly);
	zero := fam!.zeroCoefficient;
	one := fam!.oneCoefficient;
	mone := -one;
	le := Length(ext);

	for i in [ le-1, le-3..1 ] do
		c := false;
		if ext[i + 1] <> one and ext[i + 1] <> mone then
			Add(r, TypesetString(ext[i + 1] : options := subOptions));
			c := true;
		fi;

		if Length(ext[i]) > 1 then
			for j in [ 1, 3 .. Length(ext[i]) - 1] do
				if 1 <> ext[i][j + 1] then
					Add(r, TypesetString(ext[i][j + 1] : options := subOptions));
				fi;
			od;
		else
			if c=false then
				Add(r, TypesetString(ext[i + 1] : options := subOptions));
			fi;
		fi;
	od;

	return r;
end);

InstallMethod(GenArgs, "rational functions (non-polynomial)", true,
[ IsRationalFunction ], 0,
function( ratf )
	local num, den;
	num := NumeratorOfRationalFunction(ratf);
	den := DenominatorOfRationalFunction(ratf);

	return [ TypesetString(num), TypesetString(den) ];
end);

InstallMethod(GenArgs, "character tables", true,
[ IsCharacterTable ], 0,
function( tbl )
	local opts, lang, ret, chars, data, i, j, entry, entryfmt, legend;
	opts := ValueOption("options");
	lang := opts.("Lang");

	ret := [];
	chars := List(Irr(tbl), ValuesOfClassFunction);
	data := CharacterTableDisplayStringEntryDataDefault(tbl);

	# Generate character substitutions.
	for i in [1..Length(chars)] do
		for j in [1..Length(chars[i])] do
			entry := CharacterTableDisplayStringEntryDefault(chars[i][j], data);
			entryfmt := EvalString(Concatenation("CtblEntry", lang));
			Add(ret, entryfmt(entry));
		od;
	od;

	# Generate Legend.
	legend := EvalString(Concatenation("CtblLegend", lang));
	Add(ret, legend(data));

	return ret;
end);

InstallMethod(GenArgs, "permutation", true,
[ IsPerm ], 0,
function ( x )
	local list;
	list := [ String(x) ];
	return list;
end);

InstallMethod(GenArgs, "fp groups", true, [ IsFpGroup ], 0,
function ( g )
	local lst, gens, rels, i, s, e, j;
	lst := [];
	gens := GeneratorsOfGroup(g);
	rels := RelatorsOfFpGroup(g);

	# Sub-powers for generators.
	for i in [1..Length(gens)] do
		s := String(gens[i]);
		e := Length(s);

		while e>0 and s[e] in CHARS_DIGITS do
			e := e-1;
		od;

		if e<Length(s) then
			Add(lst, s{[1..e]});
			Add(lst, s{[e+1..Length(s)]});
		else
			Add(lst, String(s));
		fi;
	od;

	for j in [1..Length(rels)] do
		Add(lst, TypesetString(rels[j]));
	od;

	return lst;
end);

InstallMethod(GenArgs, "pc groups", true, [ IsPcGroup ], 0,
function ( g )
	local lst, iso, fp;
	iso := IsomorphismFpGroupByPcgs(FamilyPcgs(g), "f");
	fp := Image(iso);

	lst := GenArgs(fp);

	return lst;
end);

InstallMethod(GenArgs, "matrix groups", true, [ IsMatrixGroup ], 0,
function ( g )
	local lst, gens, i;
	lst := [];
	gens := GeneratorsOfGroup(g);

	for i in [1..Length(gens)] do
		Add(lst, TypesetString(gens[i]));
	od;

	return lst;
end);

InstallMethod(GenArgs, "permutation groups", true, [ IsPermGroup ], 0,
function ( g )
	local lst, gens, i;
	lst := [];
	gens := GeneratorsOfGroup(g);

	for i in [1..Length(gens)] do
		Add(lst, String(gens[i]));
	od;

	return lst;
end);

InstallMethod(GenArgs,"assoc word in letter rep",true,
[IsAssocWord and IsLetterAssocWordRep],0,
function( elm )
	local opts, lang, orig, names, new, i, e, s, l, substr, factorise;
	opts := ValueOption("options");
	lang := opts.("Lang");

	# Generate names using subscript over . notation
	orig := FamilyObj(elm)!.names;
	new := ShallowCopy(orig);
	names := EvalString(Concatenation("GenNameAssocLetter", lang));
	for i in [1..Length(new)] do
		new[i] := names(new[i]);
	od;

	# Factorise word as power of substrings
	l := LetterRepAssocWord(elm);
	factorise := EvalString(Concatenation("FactoriseAssocWord", lang));
	substr := factorise(l, new, []);

	return [ substr ];
end);

#############################################################################
##
#M  MergeSubOptions( <options record> ) . 
##  
## generates a new options record that can be passed to sub-calls from a parent.
## used to allow users to set options that may differ between recursive calls
## of a single method (e.g. Matrix delimitors).
##
InstallMethod(MergeSubOptions, "for generating alternative sub-call options", true,
[ IsRecord ], 0,
function ( opts )
	local subOptions, tempSub, name;

	subOptions := opts;
	if IsRecord(opts.("SubCallOpts")) then
		tempSub := opts.("SubCallOpts");
		Unbind(opts.("SubCallOpts"));
		for name in RecNames(tempSub) do
			subOptions.(name) := tempSub.(name);
		od;
	fi;

	return subOptions;
end);