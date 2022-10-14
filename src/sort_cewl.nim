import os
import strutils

proc Sort(filename:string,min:int): void =
    let wordlist = open(filename, fmRead)
    defer: wordlist.close()

    var line : string
    while wordlist.read_line(line):
        var parsing=rsplit(line,",",maxsplit=2)
        let word = parsing[0]
        var occurence :string =rsplit(parsing[^1]," ")[1]
        try:
            let occ_int:int=parseInt(occurence)
            if occ_int < min:
                return
            echo word
        except ValueError:
            continue
            # Surely a mail
            # var username :string =rsplit(occurence,"@")[0]
            # echo username

when isMainModule:
    if len(commandLineParams())!=2:
        echo "Wrong argument number: sort_cewl [cewl_wordlist] [minimum occurence]"
        quit QuitFailure
    
    let wordlist:string  = commandLineParams()[0]
    var min:int 
    try:
        min = parseInt(commandLineParams()[1])
    except ValueError:
        echo "Provide a valid number: sort_cewl [cewl_wordlist] [minimum occurence]"
    Sort(wordlist,min)
