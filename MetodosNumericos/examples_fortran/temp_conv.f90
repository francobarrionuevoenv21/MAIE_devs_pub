program kelv_to_cels
    implicit none

    real, parameter :: k_conv = 273.15 ! parameter --> This is a constant. Its value is fixed and cannot change.
    real :: t_kelv, t_cels

    print *, 'Enter T in Kelvin: '
    read(*,*) t_kelv

    t_cels = t_kelv - k_conv

    print '(A, F8.2)', 'T in ºC: ', t_cels
    ! A and F format descritptors
    ! A --> Print a string (character variable)”
    ! F8.2 --> F: floating point; 8: total width (number of characters); .2: number of decimal places

end program kelv_to_cels