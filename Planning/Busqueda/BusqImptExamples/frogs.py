rocks_ini = ["g", "g", "g", "v", "b", "b" , "b"]

rocks_obj = ["b", "b", "b", "v", "g", "g", "g"]

print(rocks_ini == rocks_obj)


print(rocks_ini)

rocks_ini[4] = "hello"

print(rocks_ini)

'''while rocks_ini != rocks_obj:

    for i, p in enumerate(rocks_ini):
        #print(i, p) 
        if p == "g":
            if i < 6:       
                if rocks_ini[i+1] == "v":
                    rocks_ini[i+1] = "g"
                    rocks_ini[i] = "v"
            
            elif (i+1) <= 6:
                if rocks_ini[i+1] == "b" and rocks_ini[i+2] == "v":
                    rocks_ini[i] = "v"
                    rocks_ini[i+1] = "b"
                    rocks_ini[i+2] = "g"
        
        elif rocks_ini == "b":

            if i > 0:       
                if rocks_ini[i-1] == "v":
                    rocks_ini[i] = "v"
                    rocks_ini[i-1] = "b"
            
            elif (i-2) >= 0:
                if rocks_ini[i-1] == "g" and rocks_ini[i-2] == "v":
                    rocks_ini[i] = "v"
                    rocks_ini[i-1] = "g"
                    rocks_ini[i-2] = "b"

    print(rocks_ini)
            '''



