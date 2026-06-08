
! Use a bisection method to compute roots
! f(x) = sin(x) − 0.3exp(x) = 0,  x > 0

! define function to solve module & function
module def_funcs
    implicit none

contains

    ! f(x) = sin(x) − 0.3exp(x) = 0,  x > 0
    function eval_f(x) result(f1)

        real :: x, f1

        f1 = sin(x) - 0.3*exp(x) ! f(x) = sin(x) − 0.3exp(x) = 0

    end function eval_f


    ! Bisection method
    subroutine bisec_met(a, b, n, tol, csv)

        integer :: n, i, csv
        real :: a, b, tol
        real :: c, err

        ! Compute c (root) first approximation
        c = (a + b) / 2.0

        ! Compute error
        err = abs(c - a)

        if (csv == 0) then ! csv = 0 (True); create a csv file
            ! Create directory to store output file
            call system('mkdir -p tp2e3b_bisecMet')

            ! Write data to file
            ! Open file
            open(unit=10, file='tp2e3b_bisecMet/outputData.csv', status='replace')
            write(10,'(A)') 'n, a_n, b_n, c_n, f(a_n), f(b_n), f(c_n), tol, r' ! A: Character string
        end if

        ! Iterate and check conditions
        do i = 1, n

            if (err <= tol) then
                print *, 'Root found at c:', c
                print *, 'Error:', err
                print *, 'Iterations:', i
                print*, 'Error < tol'
                

                ! Store data in the csv
                if (csv == 0) then
                    write(10,*) i, a, b, c, eval_f(a), eval_f(b), eval_f(c), tol, err
                    close(10)
                end if

                return

            else if (eval_f(a) * eval_f(c) > 0.0) then

                    a = c
                    c = (a + b) / 2.0
                    err = abs(c - a)

                    ! Store data in the csv
                    if (csv == 0) then
                        write(10,*) i, a, b, c, eval_f(a), eval_f(b), eval_f(c), tol, err
                    end if

                else if (eval_f(a) * eval_f(c) < 0.0) then

                    b = c
                    c = (a + b) / 2.0
                    err = abs(c - a)

                    ! Store data in the csv
                    if (csv == 0) then
                        write(10,*) i, a, b, c, eval_f(a), eval_f(b), eval_f(c), tol, err
                    end if

                else if (eval_f(a) * eval_f(c) == 0.0) then

                    print *, 'Root found at c:', c
                    print *, 'Error:', err
                    print *, 'Iterations:', i
                    print*, 'f(a) * f(c) = 0'

                    ! Store data in the csv
                    if (csv == 0) then
                        write(10,*) i, a, b, c, eval_f(a), eval_f(b), eval_f(c), tol, err
                        close(10)
                    end if

                    return 

            end if

        end do

        ! Store data in the csv
        if (csv == 0) then
            write(10,*) i, a, b, c, eval_f(a), eval_f(b), eval_f(c), tol, err
            close(10)
        end if

        print *, 'Maximum iterations reached.'
        print *, 'Last root estimate:', c
        print *, 'Last error:', err

    end subroutine bisec_met

end module def_funcs

! -- 
program root_bisec_met
    use def_funcs
    implicit none

    integer :: n, n_ip, d_inp, csv, csv_inp
    real :: a, b, d, tol

    ! Variables initialization
    n = 10000 ! max iterations
    d = 4
    tol = 1.0/(10.0**d) ! Define tolerance

    ! Initialization print
    print *, 'f(x) = sin(x) - 0.3exp(x) = 0,  x > 0 roots solver'

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

    print *, 'Create csv file with output (True: 0; False: 1)'
    read(*,*) csv_inp
    if (csv_inp == 0) then
        csv = csv_inp
    end if

    ! --
    call bisec_met(a, b, n, tol, csv)


end program root_bisec_met