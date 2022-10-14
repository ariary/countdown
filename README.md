# c o u n t d o w n

## G O A L

* *(blackbox)* have an idea of the password list size before trying to generate it
* *(whitebox)* show the strength/weakness of a password considering specific attacker capabilities without having to generate the wordlist (and perform bruteforce)

## A P P R O A C H

1. **Construct a wordlist**

Try to enumerate some possible words that could be used in the password

I recommend using [`cewl`](https://github.com/digininja/CeWL) if targetting a company to do so:
```shell
# extract word that are repeated at least 115 times in the company site
» cewl --with-numbers -c https://[TARGET] > cewl_count.txt
» sort_cewl cewl_count.txt 15 > min_15_from_cewl.txt
```

2. **Construct "extra" wordlist (include special characters + other custom ones)**
```shell
# include most used special characters in password + some dates
» seq 0 100 > extra.txt && seq 1950 2050 >> extra.txt
```

3. **Provide constraint model**

***👋 TL;DR here***

It is possible to play with:
 * The substitution numbers in words (*e.g* `A` to `4`)
 * The numbers of Uppercase letters in words
 * The number of words from the wordlist
 * The number of extra-words from the wordlist and their position

```shell
# Compute different variables about wordlist
» LEN_WORDLIST=$(cat min_15_from_cewl.txt | wc -l)
» AVG_WORD_SIZE=$(( $(cat min_15_from_cewl.txt | wc -c) / $(cat min_15_from_cewl.txtt | wc -w) ))
» LEN_EXTRA_WORDLIST=$(cat extra.txt | wc -l)
# How many passwords possible if:
# max 2 words from the wordlist are possible
# max 3 substitutions by word
# max 2 words from extra wordlists can follow each other
# max 1 uppercase letter by word
» countdown --len "${LEN_WORDLIST}" --lenExtra "${LEN_EXTRA_WORDLIST}" --meanWordLength=7 --maxSubstitution=3 --extraFollowing=2 --max-upper=1
```

## .. I want to use it
Install `nim`
```shell
» git clone https://github.com/ariary/countdown && cd countdown && make build.countdown && make build.sort_cewl
```

## Disclaimer

* I am pretty sure similar projects already exist and may be better, but my google fu skills were not sufficient to find them (btw I like making my own tools)
* I try my best to make the right compute, considering the different constraints, but some mistakes might be present (enumeration logic can be very confusing sometimes)

## Supplementary notes

With a cluster of GPU *(like the ZOTAC GTX 1050 Ti Min)* it is theorically possible to crack tens of millions more hashes per second. It is affordable.

* So you can have an idea about how many seconds you need to test against the wordlist by dividing the #Passwords by 10 000 000
* Divide the previous result by 86400 to get an idea in days

