! This program calculates a linear temperature profile in 1D and writes the results to a file.

! define defStep to calculate the step size
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

! define linGradfunc to calculate the linear gradient
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

! main program to calculate the temperature profile and write to file
program temp1DProf_wOut
    use linGradfunc
    implicit none

    real :: T_start, T_end
    integer :: N
    integer :: i

    real, allocatable :: arrayTprof(:)

    ! Create directory to store output file
    call system('mkdir -p prof1DDataOut')

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

    ! Write data to file
    ! Open file
    open(unit=10, file='prof1DDataOut/profData.txt', status='replace')

    ! Write data
    do i = 1, N
        write(10,*) i, arrayTprof(i)
    end do

    close(10)

    deallocate(arrayTprof)

end program temp1DProf_wOut