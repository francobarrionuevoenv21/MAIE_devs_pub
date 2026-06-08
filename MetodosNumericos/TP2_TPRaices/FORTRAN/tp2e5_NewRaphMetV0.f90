! Newton-Raphson method implementation
module newRaph_mod
    implicit none

contains

    ! f(x) = log(1 + x) - x^2
    function eval_f(x) result(f1)

        real :: x, f1

        f1 = log(1.0 + x) - x**2

    end function eval_f

    ! f'(x) = 1/(1+x) - 2x
    function eval_fprima(x) result(f1)

        real :: x, f1

        f1 = (1.0/(1.0+x)) - 2.0*x

    end function eval_fprima

    ! Newton-Raphson implementation
    subroutine newRaph_met(p0, tol_v, tol_h, nmax)

        integer :: i, nmax
        real :: p0, pk, tol_v, tol_h, err_v, err_h

        ! Check if p0 is a root
        if (p0 == 0.0) then
            print *, 'Root found at:', p0
            return
        end if

        ! Compute first approximation
        pk = p0 - (eval_f(p0)/eval_fprima(p0))

        ! Compute vertical error
        err_v = abs(eval_f(pk))

        ! Compute horizontal error
        err_h = abs(pk - p0)

        ! Iterate and check conditions
        do i = 1, nmax

            if (eval_fprima(pk) == 0.0) then

                print *, 'Derivative is zero at:', pk
                print *, 'Method cannot continue.'
                return

            else if (err_v <= tol_v .or. err_h <= tol_h) then

                print *, 'Root found at:', pk
                print *, 'Vertical error:', err_v
                print *, 'Horizontal error:', err_h
                print *, 'Iterations:', i
                return

            else

                p0 = pk
                pk = pk - (eval_f(pk)/eval_fprima(pk))

                ! Update errors
                err_v = abs(eval_f(pk))
                err_h = abs(pk - p0)

            end if

        end do

        print *, 'Maximum iterations reached.'
        print *, 'Last root estimate:', pk
        print *, 'Vertical error:', err_v
        print *, 'Horizontal error:', err_h
        print *, 'Iterations:', nmax

    end subroutine newRaph_met

end module newRaph_mod

! -- 
program root_newRaph_met
    use newRaph_mod
    implicit none

    integer :: n, n_ip, d, d_inp
    real :: p0, tol_v, tol_h

    ! Variables initialization
    n = 10000 ! max iterations
    d = 4

    ! Initialization print
    print *, 'log(1 + x) - x^2 roots solver'

    ! Define inputs
    print *, 'Enter the p0:'
    read(*,*) p0

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

    ! Compute tolerance
    tol_v = 1.0/(10.0**d) ! Define tolerance
    tol_h = 1.0/(10.0**d) ! Define tolerance

    ! --
    call newRaph_met(p0, tol_v, tol_h, n)

end program root_newRaph_met
