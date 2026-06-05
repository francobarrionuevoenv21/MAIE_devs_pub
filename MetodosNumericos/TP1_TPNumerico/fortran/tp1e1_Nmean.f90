! Problema 1: Escribir una funcion que realice el promedio de tres n´umeros reales. ¿Como generalizarıas
! esta funcion de modo tal que pueda calcular el promedio de una cantidad N arbitraria de numeros?

program n_mean
    implicit none ! forces to declare every variable before using it.

    integer :: i, n
    real :: mean_acum, res, r

    ! Allocatable array
    integer, allocatable :: arrayn(:) ! Allows us to define the size of the array at runtime.

    ! Initialization
    mean_acum = 0 

    print *, 'Enter the number of elements:'
    read(*,*) n

    ! array allocation according to the user defined n size
    allocate(arrayn(n))

    ! Initialize the random number generator
    call random_seed()

    ! Fill the array with random integers between 1 and 200
    do i = 1, n
        call random_number(r) ! r ranges from 0 <= r < 1
        arrayn(i) = int(r * 200) + 1 ! Scale to 1-200
        mean_acum = mean_acum + arrayn(i) ! Accumulate the sum for mean calculation
    end do

    ! Compute mean
    res = mean_acum / n

    ! Output
    print *, 'Array:', arrayn
    print '(A, F8.2)', 'Array mean value: ', res ! A: string, F8.2: float with 8 characters width and 2 decimal places

    ! Free memory
    deallocate(arrayn)

end program n_mean