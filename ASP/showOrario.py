import os
import datetime

def main():
    start = datetime.datetime.now()
    startDayAndTime = start.strftime("%d/%m/%Y %H:%M:%S")
    print('Start solving at: ' + startDayAndTime)
    os.system('clingo completo.cl > output.txt')
    f = open("output.txt", "r")
    listaGiorni = ['LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB']
    output = ''
    i = 0
    for x in f:
        if i == 4 : 
            output = x
        i = i+1
    listaLezioni = output.split(' ')
    stringalezioni = ''
    for settimana in range(1,25) :
        print("#SETTIMANA " + str(settimana))
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
    stop = datetime.datetime.now()
    stopDayAndTime = stop.strftime("%d/%m/%Y %H:%M:%S")
    print('Stopped solving at: ' + stopDayAndTime)

    execution = stop - start
    print('Duration of execution: ')
    print(execution)
        
        

if __name__== "__main__":
  main()