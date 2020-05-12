import os
import datetime

def main():
    output = ''
    start = datetime.datetime.now()
    startDayAndTime = start.strftime("%d/%m/%Y %H:%M:%S")
    print('Start solving at: ' + startDayAndTime)
    os.system('clingo demo_progetto.cl > output.txt')
    stop = datetime.datetime.now()
    f = open("output.txt", "r")
    listaGiorni = ['LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB']
    output2 = ''
    i = 0
    for x in f:
        if i == 4 : 
            output = x
        i = i+1
    listaLezioni = output.split(' ')
    stringalezioni = ''
    numSettimane = 24
    for settimana in range(1,numSettimane + 1) :
        print("#SETTIMANA " + str(settimana))
        output2 += "#SETTIMANA " + str(settimana) + "\n"
        for giorno in range(1,7) :
            stringalezioni = ''
            for ora in range(1,9) :
                for x in listaLezioni :
                    lez = x[8:x.rindex(')')]
                    nn = lez.split(',')
                    if int(nn[1]) == settimana and int(nn[2]) == giorno and int(nn[3]) == ora :
                        stringalezioni += "\t\t" +str(ora) + " : " + nn[0] + "\n"
            
            if stringalezioni != '' :
                print("\t" + listaGiorni[giorno-1])
                print(stringalezioni)
                output2 += "\t" + listaGiorni[giorno-1]
                output2 += "\n" + stringalezioni
    
    stopDayAndTime = stop.strftime("%d/%m/%Y %H:%M:%S")
    print('Started solving at: ' + startDayAndTime)
    print('Stopped solving at: ' + stopDayAndTime)

    execution = stop - start
    print('Duration of execution: ')
    print(execution)
    f = open("Lezioni.txt", "w")
    f.write(output2)
    f.close()    
        

if __name__== "__main__":
  main()