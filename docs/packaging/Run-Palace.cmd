@echo off
setlocal
rem Validated one-rank baseline: retain MPI shared-memory transport only.
set MSMPI_DISABLE_SOCK=1
set MSMPI_DISABLE_ND=1
if not defined OMP_NUM_THREADS set OMP_NUM_THREADS=1
if not defined MKL_NUM_THREADS set MKL_NUM_THREADS=1
"%~dp0palace.exe" %*
exit /b %errorlevel%
