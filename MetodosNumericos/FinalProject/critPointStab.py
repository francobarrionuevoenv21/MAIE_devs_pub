# Import libraries
import cmath

# Define jacobian Matrix function
def jac_max_2d(df_dx, df_dy, dg_dx, dg_dy, x_cp, y_cp):

    a = df_dx(x_cp, y_cp)
    b = df_dy(x_cp, y_cp)
    c = dg_dx(x_cp, y_cp)
    d = dg_dy(x_cp, y_cp)

    return a, b, c, d

# Define Bhaskara solver to get eigenvalues
def get_eigenval(df_dx, df_dy, dg_dx, dg_dy, x_cp, y_cp):

    a, b, c, d = jac_max_2d(df_dx, df_dy, dg_dx, dg_dy, x_cp, y_cp)
    #print(a, b, c, d)

    bhask_a = 1
    bhask_b = (-1)*(a + d)
    bhask_c = (a*d-b*c)

    eigV1 = ((-bhask_b) + cmath.sqrt(bhask_b**2-4*bhask_a*bhask_c))/(2*bhask_a)
    eigV2 = ((-bhask_b) - cmath.sqrt(bhask_b**2-4*bhask_a*bhask_c))/(2*bhask_a)

    return eigV1, eigV2

# Define critical point stabilizity function
def cp_stab(df_dx, df_dy, dg_dx, dg_dy, x_cp, y_cp):

    # Gen eigenvalues result
    eigV1, eigV2 = get_eigenval(df_dx, df_dy, dg_dx, dg_dy, x_cp, y_cp)

    # Print critical point
    print(f'X*: {x_cp}; Y*: {y_cp}')

    # Print eigenvalues
    print(f'Lambda1: {eigV1}; Lambda2: {eigV2}')

    if eigV1.imag != 0 or eigV2.imag != 0: # Check if eigenvalues has an imaginary component

        if abs(eigV1.real) < 1e-12 and abs(eigV2.real) < 1e-12: # No real component
            print('Centro. Estable')

        elif eigV1.real > 0:
            print('Punto espiral. Inestable')

        else:
            print('Punto espiral. Asintóticamente estable')

    else: # Eigenvalues with no imaginary component

        eigV1 = eigV1.real
        eigV2 = eigV2.real

        if eigV1 > 0 and eigV2 > 0: # Positive values

            if eigV1 == eigV2:
                print('Nodo propio/Impropio. Inestable')

            else: # eigV1 > eigV2 or eigV1 < eigV2
                print('Nodo impropio. Inestable')

        elif eigV1 < 0 and eigV2 < 0:

            if eigV1 == eigV2:
                print('Nodo propio/Impropio. Asintóticamente estable')

            else: # eigV1 > eigV2 or eigV1 < eigV2
                print('Nodo impropio. Asintóticamente estable')

        elif eigV1 * eigV2 < 0:
            print('Punto silla. Inestable')