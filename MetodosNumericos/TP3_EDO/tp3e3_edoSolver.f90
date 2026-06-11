! Resolver la EDO dxdt = (t-x)/2
! en el intervalo [0,3] con x(0) = 1 y para los siguientes cuatro valores de h = 1, 0,5, 0,25, 0,125.
! Resolvé exactamente el problema determinando su dominio de definici´on y compar´a el error final (en t = 3)
! los cuatro casos. Donde x(t) = t−2+cexp(−t/2) con c = 3.

!--
module function_ode

contains

    ! ODE definition
    function f_ode(t, x) result(dxdt)

        real :: t, x
        real :: dxdt

        ! dx/dt = (t-x)/2
        dxdt = (t - x)/2.0

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
    !t0 = 0.0
    !tf = 3.0
    !x0 = 1.0
    !h  = 1

    ! Let user redefine conditions
    print *, 't0:'
    read(*,*) t0

    print *, 'tf:'
    read(*,*) tf

    print *, 'x0:'
    read(*,*) x0

    print *, 'h:'
    read(*,*) h

    print*, 'Output file name suffix:'
    read(*,*) suffix


    !-
    call system('mkdir -p tp3e3')
    u_file = 10
    open(unit=u_file, file='tp3e3/output_' // trim(suffix) // '.csv', status='replace')

    ! Call Euler solver
    call euler(f_ode, t0, tf, x0, h, u_file)

end program solve_edo_euler
    