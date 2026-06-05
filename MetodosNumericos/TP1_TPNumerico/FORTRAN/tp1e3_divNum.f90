! Problema 3: Escribir un programa que pida un n´umero entero y determine si es m´ultiplo de 2 y de 5.

program div_num
    implicit none

    integer :: num

    print *, 'Enter an integer:'
    read(*,*) num

    if (mod(num, 2) == 0 .and. mod(num, 5) == 0) then ! mod(a, b) returns the remainder of a divided by b. If the result is 0, it means a is a multiple of b.
        print '(A, I8)', 'The number ', num, ' is a multiple of both 2 and 5.'
    else if (mod(num, 2) == 0) then
        print '(A, I8)', 'The number ', num, ' is a multiple of 2 but not of 5.'
    else if (mod(num, 5) == 0) then
        print '(A, I8)', 'The number ', num, ' is a multiple of 5 but not of 2.'
    else
        print '(A, I8)', 'The number ', num, ' is not a multiple of either 2 or 5.'
    end if

end program div_num