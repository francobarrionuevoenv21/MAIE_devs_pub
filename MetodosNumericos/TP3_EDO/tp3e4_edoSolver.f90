! Resolver la EDO dNdt = r*N*(1-N/K)
! 

!--
module function_ode

contains

    ! ODE definition
    function f_ode(t, x) result(dxdt)

        real :: t, x, r, k ! x ~ N
        real :: dxdt

        ! Initialize variables
        r = 2
        k = 100

        ! dNdt = r*N*(1-N/K)
        dxdt = r*x*(1.0-(x/k))

    end function f_ode

! --
end module function_ode

program solve_edo_euler

    use euler_solver
    use function_ode
    implicit none

    real :: t0, tf, x0, h
    integer :: u_file
    character(len=10) :: suffix

    ! Initial conditions
    t0 = 0.0
    tf = 50.0
    !x0 = 1.0
    h  = 0.1

    ! Let user redefine conditions
    !print *, 't0:'
    !read(*,*) t0

    !print *, 'tf:'
    !read(*,*) tf

    print *, 'N(0):'
    read(*,*) x0

    !print *, 'h:'
    !read(*,*) h

    print*, 'Output file name suffix:'
    read(*,*) suffix


    !-
    call system('mkdir -p tp3e4')
    u_file = 10
    open(unit=u_file, file='tp3e4/output_' // trim(suffix) // '.csv', status='replace')

    ! Call Euler solver
    call euler(f_ode, t0, tf, x0, h, u_file)

end program solve_edo_euler
    