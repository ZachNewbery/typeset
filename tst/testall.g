#
# latexgen: Automatic LaTeX string generation for common GAP objects
#
# This file runs package tests. It is also referenced in the package
# metadata in PackageInfo.g.
#
LoadPackage( "latexgen" );

TestDirectory(DirectoriesPackageLibrary( "latexgen", "tst" ),
  rec(exitGAP := true));

FORCE_QUIT_GAP(1); # if we ever get here, there was an error
