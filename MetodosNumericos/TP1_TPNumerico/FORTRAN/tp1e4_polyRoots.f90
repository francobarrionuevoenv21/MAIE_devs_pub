! Problema 4: Escriba un programa que ingrese los coeficientes A, B y C de un polinomio real de segundo
! grado (Ax2 + Bx+C), calcule e imprima en pantalla las dos raıces del polinomio en formato complejo x+iy.

program poly_roots
    implicit none
    real :: A, B, C
    real :: a_r, b_r, c_r
    real :: discriminant, x1_r, x2_r
    complex :: x1_c, x2_c

    ! Define random coefficients for the polynomial
    call random_seed()

    call random_number(a_r)
    A = a_r * 50 + 1 ! Scale to 1-50; allow irracional coefficients
    call random_number(b_r)
    B = b_r * 50 + 1 
    call random_number(c_r)
    C = c_r * 50 + 1 

    ! Compute discriminant
    discriminant = B*B-(4*A*C)

    ! Check discriminant
    if (discriminant < 0) then
        x1_c = cmplx(-B, sqrt(-discriminant)) / (2*A)
        x2_c = cmplx(-B, -sqrt(-discriminant)) / (2*A)

        print *, 'Solution', A, 'x^2 +', B, 'x +', C
        print *, 'Root 1 = ', x1_c
        print *, 'Root 2 = ', x2_c

    else
        x1_r = (-B + sqrt(discriminant))/(2*A)
        x2_r = (-B - sqrt(discriminant))/(2*A)
        
        print *, 'Solution', A, 'x^2 +', B, 'x +', C
        print *, 'Root 1 = ', x1_r
        print *, 'Root 2 = ', x2_r

    end if

end program poly_roots




    
