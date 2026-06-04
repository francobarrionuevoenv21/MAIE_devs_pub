! Problema 2: Escribir un programa que pida dos n´umeros reales e imprima en la pantalla el mayor de
! ellos. El programa debe indicar si los n´umeros son iguales.

program max_number
    implicit none

    real :: num1, num2

    print *, 'Enter the first number:'
    read(*,*) num1

    print *, 'Enter the second number:'
    read(*,*) num2

    if (num1 > num2) then
        print '(A, F8.2)', 'The greater number is: ', num1
    else if (num2 > num1) then
        print '(A, F8.2)', 'The greater number is: ', num2
    else
        print *, 'The numbers are equal.'
    end if

end program max_number