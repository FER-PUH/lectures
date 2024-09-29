'use strict'


/*
   This is how you can test it out (you must be running Node 6.x.x):

   bash> node --harmony-tailcalls
   node> .load demo.js
   node> factNormal(5)
   node> factAccumulator(5, 1)
   node> factNormal(-1)
   node> factAccumulator(-1, 1)

   Depending on the engine, the last expression will either never terminate
   (i.e., the engine employs TCO), or cause a stack overflow (the engine
   doesn't employ TCO). To get the expression to loop ininitely, you must run
   the the code in Safari, or in Node 6.x.x with '--harmony-tailcalls'.

   Extra - the sad story about TCO in JavaScript:
     - https://stackoverflow.com/a/37224563
     - https://stackoverflow.com/a/54721813
     - https://kangax.github.io/compat-table/es6/
*/

function factNormal(n) {
    if (n == 0) {
        return 1
    }
    return n * factNormal(n - 1)
}

function factAccumulator(n, acc) {
    if (n == 0) {
        return acc
    }
    return factAccumulator(n - 1, n * acc)
}
