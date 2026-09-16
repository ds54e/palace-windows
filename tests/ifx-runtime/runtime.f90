subroutine runtime_value(value) bind(C)
  use iso_c_binding
  implicit none
  real(c_double), intent(out) :: value
  real(c_double), allocatable :: data(:)
  allocate(data(2))
  data = 1.0_c_double
  value = sum(data)
  write(*,*) 'ifx runtime linked through C++: ', value
  deallocate(data)
end subroutine
