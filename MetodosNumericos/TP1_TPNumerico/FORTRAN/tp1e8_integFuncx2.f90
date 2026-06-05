! Problema 8: Escribir un programa que permita calcular el ´area que est´a bajo la curva f(x) = x2 en el
! intervalo I = [0,1]. Para ello, divida el intervalo I en N partes iguales y aproxime el ´area total como la
! suma de cada una de las N ´areas peque˜nas. Calcule el resultado para varios valores de N.

! define ---
module def_func
    implicit none
contains
    function get_func(x) result(f)
        real :: x, f

        f = x**2  ! f(x) = x^2

    end function get_func
end module def_func

! Define program integ_func_x2
program integ_func_x2
    use def_func
    implicit none

    integer :: i, n, a, b
    real :: delta, x_acum, res

    ! Initialize variables
    a = 0
    b = 1
    !x_acum
    res = 0

    ! Initialization print
    print *, 'integral (',a,'-',b,') de f(x) = x^2 solver:'

    ! n user definition
    print *, 'Ingresa el número de particiones del dominio (n):'
    read *, n

    ! Compute delta
    delta = real(b-a)/real(n)
    x_acum = delta ! This define the solution by its upper limit

    ! -
    do i = 1, n
        ! print *, i, x_acum
        res = res + (delta*get_func(x_acum))
        x_acum = x_acum + delta
    end do

    print *, 'Solucion integral (',a,'-',b,') de f(x) = x^2:', res

end program integ_func_x2