subroutine pw_fortran_check(comm, result, integer_bits, logical_bits, complex_bytes) bind(C)
  use iso_c_binding
  use, intrinsic :: ieee_arithmetic
  implicit none
  include 'mpif.h'
  integer(c_int), value :: comm
  integer(c_int), intent(out) :: result, integer_bits, logical_bits, complex_bytes
  integer :: rank, nproc, ierr, sent, received, name_length
  integer :: n, nrhs, lda, ldb, ipiv(2), info
  real(c_double) :: a(2,2), b(2), residual(2)
  complex(c_double_complex) :: z(2), w(2), answer
  complex(c_double_complex), external :: zdotc
  logical :: flag
  character(len=MPI_MAX_PROCESSOR_NAME) :: processor_name
  external :: MPI_Comm_rank, MPI_Comm_size, MPI_Allreduce, MPI_Get_processor_name, dgesv
  result = 1
  integer_bits = storage_size(n)
  logical_bits = storage_size(flag)
  complex_bytes = int(c_sizeof(z(1)), c_int)
  if (integer_bits /= 32 .or. logical_bits /= 32 .or. complex_bytes /= 16) return
  call MPI_Comm_rank(comm, rank, ierr)
  if (ierr /= MPI_SUCCESS .or. rank /= 0) return
  call MPI_Comm_size(comm, nproc, ierr)
  if (ierr /= MPI_SUCCESS .or. nproc /= 1) return
  sent = 123456789
  call MPI_Allreduce(sent, received, 1, MPI_INTEGER, MPI_SUM, comm, ierr)
  if (ierr /= MPI_SUCCESS .or. received /= sent) return
  ! Exercise the hidden CHARACTER-length argument convention of msmpifec64.
  call MPI_Get_processor_name(processor_name, name_length, ierr)
  if (ierr /= MPI_SUCCESS .or. name_length <= 0 .or. name_length > len(processor_name)) return
  n = 2
  nrhs = 1
  lda = 2
  ldb = 2
  a = reshape([3.0_c_double,1.0_c_double,1.0_c_double,2.0_c_double], [2,2])
  b = [9.0_c_double,8.0_c_double]
  call dgesv(n, nrhs, a, lda, ipiv, b, ldb, info)
  if (info /= 0) return
  if (.not. all(ieee_is_finite(b))) return
  residual = [3*b(1)+b(2)-9, b(1)+2*b(2)-8]
  if (any(abs(residual) > 1.0e-12_c_double + 1.0e-12_c_double * 9)) return
  z = [cmplx(1,2,c_double),cmplx(3,-1,c_double)]
  w = [cmplx(2,-1,c_double),cmplx(-1,4,c_double)]
  answer = zdotc(2,z,1,w,1)
  if (.not. ieee_is_finite(real(answer)) .or. .not. ieee_is_finite(aimag(answer))) return
  if (abs(answer - cmplx(-7,6,c_double)) > 1.0e-12_c_double) return
  result = 0
end subroutine
