// Just a small arrow function example, they are kinda like lambdas
export const add = (x, y) => {
  return x + y;
};

// What we're used to
export const concatThreeUncurried = (str1, str2, str3) => {
  return str1 + str2 + str3;
};

// Curried form
export const concatThreeCurried = (str1) => {
  return (str2) => {
    return (str3) => {
      return str1 + str2 + str3;
    };
  };
};

export const result1 = concatThreeUncurried("Foo", "Bar", "Baz");
// Q: how do we call the curried version?
