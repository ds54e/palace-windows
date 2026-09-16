Palace Windows x64 V1.0 — internal validation candidate

This package is not yet approved for redistribution or release. Read
REDISTRIBUTION_REVIEW.md for unresolved publisher/license facts.
Target: Windows 11 x64. No administrator rights, Python, WSL, SDK, MPI
installation or Intel runtime installation should be needed. Independent
clean-machine validation is still required before that claim is accepted.
This candidate is unsigned.

Extract the complete folder to a user-writable location. Keep palace.exe,
palace-sparams.exe and every supplied DLL together. Do not install DLLs in
Windows directories. Copy an examples subfolder to your desired writable
working location; use a command prompt in that copied folder:

  set OMP_NUM_THREADS=1
  set MKL_NUM_THREADS=1
  "C:\path to Palace\palace.exe" config.json > run.log 2>&1

The example mesh path and output folder are relative to that working
folder. ParaView can open the generated .pvd/.pvtu files; ParaView itself is
optional and is not included. For the driven example (ports 1 and 2, 50 ohms):

  "C:\path to Palace\palace-sparams.exe" output\port-S.csv output.s2p 50 1 2

Read TOUCHSTONE.md before exporting other models. The exporter requires the
actual common real reference impedance and does not renormalize results.

The supported V1 baseline is one MPI rank and one thread on the CPU:
electrostatic capacitance, magnetostatic inductance, driven lumped-port
complex S-parameters and basic linear eigenmodes. This build uses Hypre,
METIS, MUMPS with PORD/METIS and ARPACK/PARPACK. ParMETIS ordering is explicitly
unsupported and fails rather than silently changing the selected ordering.
GPU, multi-rank scaling and broader upstream features are not validated.

Third-party rights
------------------
Run palace.exe --licenses for attribution and the license/source locations.
Palace and this overlay retain their Apache-2.0 terms. Other components have
separate licenses in licenses/. The vendor runtime terms apply only to the
respective proprietary components, not to unrelated open-source code.

This software uses MUMPS 5.7.3:
Copyright 1991-2024 CERFACS, CNRS, ENS Lyon, INP Toulouse, Inria,
Mumps Technologies, University of Bordeaux.
MUMPS is governed by CeCILL-C with the exceptions identified in its LICENSE.
See licenses/mumps/ and sources/MUMPS_5.7.3.tar.gz. Source is included offline.
Eigen covered source and other corresponding source snapshots are likewise
included in sources/. These libraries are provided without the warranties
and subject to the liability limitations in their respective licenses.

The Microsoft MPI and Intel proprietary runtime components are provided
only for use with this product, under their accompanying terms. Do not
reverse engineer, decompile or disassemble those proprietary components,
except to the extent applicable law or an applicable third-party license
expressly permits it. No upstream vendor certifies, endorses, supports or
guarantees this Windows distribution. Vendor warranty/liability limitations
in the accompanying agreements remain applicable. See RUNTIME_TERMS.txt.

Uninstall: remove the extracted package folder. Your separate inputs and
outputs are not deleted. No service, registry setting or system runtime is
installed by this portable package.
