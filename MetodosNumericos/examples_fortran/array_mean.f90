program array_mean
    implicit none

    ! Variables
    integer :: n_int, l_array, mean_acum
    integer :: i
    real :: res

    ! Allocatable array
    integer, allocatable :: array1(:) ! Allows us to define the size of the array at runtime.

    ! Initialization
    l_array = 10
    mean_acum = 0

    ! Allocate memory
    allocate(array1(l_array))

    ! Input + accumulation
    do i = 1, l_array
        print *, 'Enter element ', i, ':'
        read(*,*) n_int

        array1(i) = n_int
        mean_acum = mean_acum + n_int
    end do

    ! Compute mean
    res = real(mean_acum) / l_array

    ! Output
    print *, 'Array:', array1
    print '(A, F8.2)', 'Array mean value: ', res

    ! Free memory
    deallocate(array1)

end program array_mean