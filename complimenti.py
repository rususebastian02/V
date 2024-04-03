list = ("Stupendo", "Bellissimo", "Favoloso", "Biricchino")
print ("● Cro è il mio pasticcino, fagli un complimento")
print ("● Lista dei complimenti disponibili:\n", list)

x = input ("Inserisci un numero compreso tra 0 a 3\n")

if x == "0" : 
    print("● Cro è", list[0])

elif x == "1" :
    print("● Cro è", list[1])

elif x == "2" :
    print("● Cro è", list[2])

elif x == "3" :
    print("● Cro è", list[3])
