function isStrongPassword(password) {
    return password.length > 12;
}

function ratePassword(password) {
    if (isStrongPassword(password)) {
        return password + " is pretty strong!";
    } else {
        return password + " is horrible.";
    }
}

console.log(ratePassword("AsStrongAsItGets"));
console.log(ratePassword());
