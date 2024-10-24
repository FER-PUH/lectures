// Just a small arrow function example, they are kinda like lambdas
const add = (x, y) => { return x + y }


// What we're used to
const concatThreeUncurried = (str1, str2, str3) => {
    return str1 + str2 + str3;
}



// Curried form
const concatThreeCurried = (str1) => {
    return (str2) => {
        return (str3) => {
            return str1 + str2 + str3
        }
    }
}


const result1 = concatThreeUncurried("Foo","Bar","Baz")
// Q: how do we call the curried version?





