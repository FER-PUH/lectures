package main

import (
    "fmt"
)

func isStrongPassword(password string) bool {
    return len(password) > 12
}

func ratePassword(password string) string {
    if isStrongPassword(password) {
        return password + " is pretty strong!"
    } else {
        return password + " is horrible."
    }
}

func main() {
    fmt.Println(ratePassword("AsStrongAsItGets"))
    fmt.Println(ratePassword("ninja"))
}
