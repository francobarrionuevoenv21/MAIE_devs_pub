
! define ---
module def_func
    implicit none
contains
    function get_fuc(x) result(f)
        real :: x, f

        f = x**2 - 4  ! Example function: f(x) = x^2 - 4

    end function get_fuc
end module def_func

program root_bisec_met
    use def_func
    implicit none

    integer :: n, n_ip, i
    real :: a, b, tol, tol_ip, c, err

    ! Variables initialization
    n = 10000 ! max iterations
    tol = 1.0e-5 ! Define tolerance

    ! Initialization print
    print *, 'f(x) = x^2 - 4 roots solver'

    ! Define inputs
    print *, 'Enter the interval [a, b]:'
    read(*,*) a, b
    print *, 'Enter the number of iterations. If 0, n = 10000:'
    read(*,*) n_ip
    if (n_ip > 0) then
        n = n_ip
    end if
    print *, 'Enter the tolerance. If 0, tol = 1.0e-5:'
    read(*,*) tol_ip
    if (tol_ip > 0) then
        tol = tol_ip
    end if

    ! Compute c (root) first approximation
    c = (a + b) / 2.0

    ! Compute error
    err = abs(c - a)

    ! Iterate and Check conditions
    do i = 1, n

        if (get_fuc(a) * get_fuc(c) > 0.0) then
            a = c
            c = (a + b) / 2.0
            err = abs(c - a)
        else if (get_fuc(a) * get_fuc(c) < 0.0) then
            b = c
            c = (a + b) / 2.0
            err = abs(c - a)
        else if (get_fuc(a) * get_fuc(c) == 0.0) then
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







