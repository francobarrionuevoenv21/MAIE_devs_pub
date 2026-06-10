
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

    subroutine euler(f_ode, t0, tf, x0, h)
        real :: t0, tf, x0, h
        real :: x, t
        integer :: i, steps

        ! Initialize variables
        x = x0
        t = t0
        steps = int(tf-t0)/h

        ! For loop to solve euler method

        do i = 1, steps
            x = x + h * f_ode(t, x)
            t = t + h

            print *, x, t
        
        end do
    
    end subroutine euler

end module euler_solver 