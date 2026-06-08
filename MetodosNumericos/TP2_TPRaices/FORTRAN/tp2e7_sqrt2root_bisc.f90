! Use a bisection method to approximate sqrt(2)
! finding the roots of f(x) = x^2 - 2,  x > 0

! define function to solve module & function
module bisec_mod
    implicit none

contains

    ! approximate sqrt(2) finding the roots of f(x) = x^2 - 2,  x > 0
    function eval_f(x) result(f1)

        real :: x, f1

        f1 = x**2 - 2 ! f(x) = x^2 - 2 = 0

    end function eval_f

    ! Bisection method
    subroutine bisec_met(a, b, n, tol)

        integer :: n, i
        real :: st, a, b, tol
        real :: c, err

        ! Define sqrt(2) solution: st
        st = 1.41421 ! 5 decimals

        ! Compute c (root) first approximation
        c = (a + b) / 2.0

        ! Compute error
        err = abs(c - st)

        ! Iterate and check conditions
        do i = 1, n

            if (err <= tol) then
                print *, 'Root found at c:', c
                print *, 'Error:', err
                print *, 'Iterations:', i
                print*, 'Error < tol'
                return

            else if (eval_f(a) * eval_f(c) > 0.0) then

                    a = c
                    c = (a + b) / 2.0
                    err = abs(c - a)

                else if (eval_f(a) * eval_f(c) < 0.0) then

                    b = c
                    c = (a + b) / 2.0
                    err = abs(c - a)

                else if (eval_f(a) * eval_f(c) == 0.0) then

                    print *, 'Root found at c:', c
                    print *, 'Error:', err
                    print *, 'Iterations:', i
                    print*, 'f(a) * f(c) = 0'
                    return 

            end if

        end do

        print *, 'Maximum iterations reached.'
        print *, 'Last root estimate:', c
        print *, 'Last error:', err

    end subroutine bisec_met

end module bisec_mod

! -- 
program root_bisec_met
    use bisec_mod
    implicit none

    integer :: n, n_ip, d_inp
    real :: a, b, d, tol

    ! Variables initialization
    n = 10000 ! max iterations
    d = 4

    ! Initialization print
    print *, 'sqrt(2) finding the roots of f(x) = x^2 - 2 approximation solver'

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

    ! Define tolerance
    tol = 1.0/(10.0**d)

    ! --
    call bisec_met(a, b, n, tol)


end program root_bisec_met