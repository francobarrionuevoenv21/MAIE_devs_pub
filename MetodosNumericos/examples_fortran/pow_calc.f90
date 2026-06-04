program pow_calc
    implicit none

    integer :: x
    real :: n, res

    print *, 'Enter base:'
    read(*,*) x

    print *, 'Enter power:'
    read(*,*) n

    res = x**n

    print '(A, ES12.3)', 'X^n:', res
    ! A and F format descritptors
    ! A --> Print a string (character variable)”
    ! ES12.2 --> ES: Exponential; 12: total width (number of characters); .3: number of decimal places

end program pow_calc

