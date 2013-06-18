#!/usr/bin/python
# Silly unboggle thing.
# You know, boggle.  That game where you make letters out of a jumble.
# Yes, this is cheating.
#
# Copyright 2011 Michael Stella
#
import sys, time

def check(word, l, la, t):
    word += l

    if '.' in t:
        if word in results:
            return

        results.append(word)

        # if there are no more words at this branch, return
        if len(tree) <= 1:
            return

    x = la

    if l:
        if l not in la: return
        i = la.find(l)

        #x = la.find(0,i) + la.find(i+1)
        x = la[0:i] + la[i:-1]

    for branch in t:
        # skip the terminator
        if t[branch] == 1: continue

        if branch not in x: continue

        check(word, branch, x, t[branch])

if __name__ == '__main__':

    letters = sys.argv[1]
    dictfile = '/usr/share/dict/words'
    #dictfile = 'words'

    starttime = time.time()
    tree = {}
    dictcount = 0
    with open(dictfile, 'r') as f:
        for line in f:
            line = line.rstrip()
            # skim junk out of the dictionary
            if len(line) < 4: continue
            dictcount += 1
    #        if not re.match(r'^[a-zA-Z]+$', line): continue

            w = tree
            for i in line:
                if i == '\n': continue

                try:
                    if i in w:
                        w = w[i]
                    else:
                        w[i] = {}
                        w = w[i]
                except: continue
            try:
                w['.'] = 1
            except: pass

    loadtime = time.time() - starttime

    results = []

    starttime = time.time()
    check('', '', letters, tree)
    runtime = time.time() - starttime


    print
    print ', '.join(results)
    print "dictionary loadtime: %f" % loadtime
    print "dictionary size: %d" % dictcount
    print "run time: %f" % runtime
    print "results found: %d" % len(results)

