
! Siendo dx/dt = f(t), x(t0) = x0.

! Los datos de entrada del programa deben ser:
! t0: tiempo inicial.
!tf: tiempo final.
! x0: x(t0), dato inicial.
! h : incremento de tiempo.
! Mientras que los datos de salida serán:
! T : vector del tiempo (abscisas).
! X : vector de aproximaciones a x(t) (ordenadas).

module euler_solver

    implicit none

contains

    subroutine euler(f_ode, t0, tf, x0, h, u_file)

        interface
            function f_ode(t, x) result(dxdt)
                real :: t, x, dxdt
            end function f_ode
        end interface

        real :: t0, tf, x0, h
        real :: x, t
        integer :: i, steps, u_file

        ! Initialize variables
        x = x0
        t = t0
        steps = int((tf - t0)/h)

        ! Euler iterations
        do i = 0, steps

            print *, t, x
            write(u_file,'(F12.6,",",F12.6)') t, x

            x = x + h * f_ode(t, x)
            t = t + h
            
        end do

    end subroutine euler

end module euler_solver