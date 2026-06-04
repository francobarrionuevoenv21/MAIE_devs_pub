program max_min
    implicit none

    ! Variables
    integer :: n_int, l_array, max_n, min_n
    integer :: i

    ! Allocatable array
    integer, allocatable :: array1(:) ! Allows us to define the size of the array at runtime.

    ! Initialization
    l_array = 10
    max_n = 0
    min_n = 0

    ! Allocate memory
    allocate(array1(l_array))

    ! Input, and check and replace max and min
    do i = 1, l_array
        print *, 'Enter element ', i, ':'
        read(*,*) n_int

        array1(i) = n_int

        if (i == 1) then
            max_n = n_int
            min_n = n_int
        else
            if (n_int > max_n) then
                max_n = n_int
            end if
            if (n_int < min_n) then
                min_n = n_int
            end if
        end if
    end do

    ! Output
    print *, 'Array:', array1
    print '(A, I0)', 'Maximum value: ', max_n
    print '(A, I0)', 'Minimum value: ', min_n   

    ! Free memory
    deallocate(array1)

end program max_min