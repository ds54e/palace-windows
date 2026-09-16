# Touchstone export

`palace-sparams.exe input.csv output.s2p 50 1 2` exports the complete two-port complex S matrix from Palace's `port-S.csv`. The last two arguments explicitly map Palace port IDs to Touchstone ports 1 and 2. For a one-port result use `output.s1p 50 1`.

The impedance argument must equal the common real reference impedance used by the Palace simulation. The utility does not renormalize S, infer impedance, or support unequal/complex reference impedances. Use matching lumped-port resistances in the configuration. Missing requested complex matrix entries are errors; no reciprocity assumption or zero filling is used. Existing output files are not overwritten.

Output is Touchstone 1.x ASCII, `# GHz S RI R <impedance>`, with the two-port order S11, S21, S12, S22. Magnitude in dB and phase in degrees are converted together. Frequencies must increase, and all input/output numbers must be finite. Original CSV results retain the solver's precision. The native Windows executable supports whitespace and Unicode paths and needs no Python installation.

Format reference: [IBIS Touchstone specifications](https://ibis.org/touchstone_ver2.0/touchstone_ver2_0.pdf), including the legacy Version 1.0 two-port convention. The exporter does not emit Version 2.0 keywords.
