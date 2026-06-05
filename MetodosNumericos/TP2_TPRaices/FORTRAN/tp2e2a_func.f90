
! Use a bisection method to compute roots of the intersection between
! f1(x) = sqrt(x2+1) and f2(x) = tan(x)

! define function to solve module & function
module def_func
    implicit none
contains
    function get_func(x) result(f_res)
        real :: x, f1, f2, f_res

        f1 = sqrt(x**2 + 1)   ! Function: f(x) = sqrt(x2+1
        f2 = tan(x)   ! Function: f(x) = sqrt(x2+1)

        f_res = f1-f2

    end function get_func
end module def_func

program root_bisec_met
    use def_func
    implicit none

    integer :: n, n_ip, i, d, d_inp
    real :: a, b, tol, c, err

    ! Variables initialization
    n = 10000 ! max iterations
    d = 4
    tol = 10/(10**d) ! Define tolerance

    ! Initialization print
    print *, 'g(x) = sqrt(x2+1) - tan(x) = 0 roots solver'

    ! Define inputs
    print *, 'Enter the interval [a, b]:'
    read(*,*) a, b
    print *, 'Enter the number of iterations. If 0, n = 10000:'
    read(*,*) n_ip
    if (n_ip > 0) then
        n = n_ip
    end if
    print *, 'Enter the digits tolerance. If 0, d = ', d, ':'
    read(*,*) d_inp
    if (d_inp > 0) then
        d = d_inp
    end if

    ! Compute c (root) first approximation
    c = (a + b) / 2.0

    ! Compute error
    err = abs(c - a)

    ! Iterate and Check conditions
    do i = 1, n

        if (get_func(a) * get_func(c) > 0.0) then
            a = c
            c = (a + b) / 2.0
            err = abs(c - a)
        else if (get_func(a) * get_func(c) < 0.0) then
            b = c
            c = (a + b) / 2.0
            err = abs(c - a)
        else if (get_func(a) * get_func(c) == 0.0) then
            print *, 'Root found at c:', c
            print *, 'Error:', err
            print *, 'n iterations:', i
            stop
        end if

        if (err <= tol) then
            print *, 'Root found at c:', c
            print *, 'With error:', err, 'and n:', i
            stop
        end if

    end do

end program root_bisec_met