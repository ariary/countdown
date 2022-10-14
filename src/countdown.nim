import terminal
import std/math
import std/algorithm
import std/sequtils

const PREFIX1:string =  ansiForegroundColorCode(fgBlue) & "[" &  ansiForegroundColorCode(fgCyan) & "*" &  ansiForegroundColorCode(fgBlue) & "]" & ansiForegroundColorCode(fgCyan) & " "
const PREFIX2:string =  ansiForegroundColorCode(fgBlue) & "[" &  ansiForegroundColorCode(fgGreen) & "*" &  ansiForegroundColorCode(fgBlue) & "]" & ansiForegroundColorCode(fgGreen) & " "
# "k parmis n"
func binomialCoeff(n, k: int): int =
  var res = 1
  var k = k
  if (k > n - k):
    k = n - k
  for i in 0 ..< k:
    res = res * (n - i)
    res = res div (i + 1)
  return res

# "partial permutation" in english I think  = n * n-1 * ... * n-k+1
func arrangement(n, k: int): int =
  var res = 1
  var k = k
  if (k > n - k):
    k = n - k
  for i in 0 ..< k:
    res = res * (n - i)
  return res

proc humanPrintableInt(n:int):string=
    var integerStr:string =  $n
    integerStr.reverse()
    var index = 0
    var resStr:string
    for i in toSeq(1..len(integerStr)).filterIt(it mod 3 == 0):
        resStr &= integerStr[index .. i-1] & " "
        index = i
    if len(integerStr)-1 mod 3 != 0:
        resStr &= integerStr[index .. len(integerStr)-1]
    
    resStr.reverse()
    return resStr


proc Count(len:int,lenExtra: int,meanWordLength:int=5,maxSubstitution:int=3,maxUpper:int=1,fixedUpper:bool=false,fixedSubstitution:bool=false,maxWords:int=2,maxExtraWords:int=3,beginWithExtra:bool=false,extraFollowing:int=1,verbose:bool=true): void =
    if extraFollowing == 0:
        echo "--extra-following must greater than 1 (otherwise it is teh same as no extra word, in this case specify --len-extra 0"
        quit QuitFailure
    
    if maxSubstitution > 2 and fixedSubstitution:
        echo "you can't have more than 2 substitions with --fixed-upper-substitution"
        quit QuitFailure

    if maxSubstitution > 2 and fixedSubstitution:
        echo "you can't have more than 2 change in Upper case with --fixed-upper-and-lower"
        quit QuitFailure
        
    # Reconstruct wordlist
    if verbose:
        styledEcho(PREFIX1,"Reconstruct wordlist",fgDefault)
    var nLen:int = len
    ## Upper
    ### We consider that all the world has been change to only be composed of lower case
    ### take all the binomial coefficient from 0 to maxUpper (maybe a properties ~2^maxUpper)
    if verbose:
        styledEcho(PREFIX2,"Add uppercase",fgDefault)
    if not fixedUpper:       
        for index in 1 .. maxUpper:
            var oneWordVariation:int = binomialCoeff(meanWordLength,index)
            let allVariations:int= len * oneWordVariation
            if verbose:
                echo "• add \"", index, " uppercase letter(s)\" case:"
                echo "\t➙ possible variation by words: ", oneWordVariation
                echo "\t➙ alls possible variations added: ", allVariations
            nLen += allVariations
    else:
        case maxUpper:
            of 1:
                nLen += len * 2 # + 1 with all word w/ first Upper + same at the end 
            of 2:
                nLen += len * 3 # + 1 with all word w/ first Upper + same at the end + upper at the beginning & end
            else:
                discard

    if verbose:
        echo "wordlist after uppercase inclusion: ", nLen
    ## Substitution (eg A -> 4)
    if verbose:
        styledEcho(PREFIX2,"Character substitution",fgDefault)
    if not fixedSubstitution:
        var added:int=0
        for index in 1 .. maxSubstitution:
            var oneWordVariation:int = binomialCoeff(meanWordLength,index)
            let allVariations:int= nLen * oneWordVariation
            if verbose:
                echo "• add \"substitute ",index," letter(s)\" case:"
                echo "\t➙ possible variation by words: ", oneWordVariation
                echo "\t➙ all possible variations added: ", allVariations
            added += allVariations
        nLen += added
    else:
        case maxSubstitution:
            of 1:
                nLen += nlen * 2 # + 1 with all word w/ first character substituted + same at the end 
            of 2:
                nLen += len * 3 # + 1 with all word w/ first character substituted + same at the end + substitution at the beginning & end
            else:
                discard
    # if verbose:
    #     echo "wordlist after substitution inclusion: ", nLen

    if verbose:
        echo "\n"
        styledEcho fgGreen, "📃 Wordlist new length: ", fgDefault, $nLen
        echo "\n"
    
    # Inject the extra wordlist
    if verbose:
        styledEcho(PREFIX1,"Construct final wordlist with extra characters",fgDefault)
    var lenFinalWordlist:int
    ## Combination of word
    styledEcho(PREFIX2,"Combinations of words from list  ",styleItalic,"(no word repetition)",fgDefault)
    for index in 1 .. maxWords:
        var wordsCombinations:int = binomialCoeff(nLen,index) # One word can't be peek twice
        ### number of insertion point for extra characters
        var entrypoints:int
        if fixedSubstitution:
            if not beginWithExtra:
                entrypoints = 1*extraFollowing
            else:
                entrypoints = 2*extraFollowing
        else:
            entrypoints =(index+1) * extraFollowing
        
        let extraWordsCombinations:int=lenExtra^entrypoints
        lenFinalWordlist += extraWordsCombinations
        if verbose:
            echo "• \"",index," word(s) from wordlist\" case:"
            echo "\t➙ possible words combinations: ", wordsCombinations
            echo "\t➙ entrypoints per combination: ", entrypoints
            echo "\t➙ possible extra words combinations: ", extraWordsCombinations
            echo "\t➙ add combination to final wordlists length: ", extraWordsCombinations

    if verbose:
        styledEcho fgGreen, "\n\n🧮 Possibilities: ", fgDefault, humanPrintableInt(lenFinalWordlist)
        echo "\n"
    else:
        echo lenFinalWordlist

when isMainModule:
    import cligen;  dispatch Count, help={
        "len": "wordlist length",
        "lenExtra": "extra wordlists length (include special character, number)",
        "meanWordLength": "mean of word length",
        "maxSubstitution": "maximum number of substitions you want for words",
        "maxUpper" :"maximum changes lower -> upper cas in a word z",
        "fixedUpper": "Upper case changes can only happen at the end and begin of words",
        "fixedSubstitution":"Substition changes can only happen at the end and begin of words",
        "maxWords": "maximum number of words from wordlist you want in password (assume not the same word twice)",
        "maxExtraWords": "maximum number of extra words from wordlist: we assume duplicate are possible",
        "beginWithExtra" :"set if extra character can be at the beginning of password",
        "extraFollowing":"how many extra characters in a row are possible" ,
        "verbose":"add verbosity (print steps)"     
    }