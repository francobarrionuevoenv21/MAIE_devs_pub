module defStep
    implicit none
contains
    function getStep(T_end, T_start, N) result(dT)
        real :: T_end, T_start
        integer :: N
        real :: dT

        dT = (T_end - T_start) / (N - 1)

    end function getStep
end module defStep


module linGradfunc
    use defStep
    implicit none
contains
    function linGrad(T_end, T_start, N, i) result(y)
        real :: T_end, T_start
        integer :: N, i
        real :: y
        real :: dT

        dT = getStep(T_end, T_start, N)
        y = dT * (i - 1) + T_start

    end function linGrad
end module linGradfunc


program temp1DProf
    use linGradfunc
    implicit none

    real :: T_start, T_end
    integer :: N
    integer :: i

    real, allocatable :: arrayTprof(:)

    print *, 'Enter T max:'
    read(*,*) T_end
    print *, 'Enter T min:'
    read(*,*) T_start
    print *, 'Enter number of steps:'
    read(*,*) N

    allocate(arrayTprof(N))

    do i = 1, N
        arrayTprof(i) = linGrad(T_end, T_start, N, i)
    end do

    print *, 'Array:', arrayTprof  

    deallocate(arrayTprof)

end program temp1DProf