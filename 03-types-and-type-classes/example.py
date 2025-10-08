def is_strong_password(password):
    return len(password) > 12


def rate_password(password):
    if is_strong_password(password):
        return password + " is pretty strong!"
    else:
        return password + " is horrible."


print(rate_password("AsStrongAsItGets"))
print(rate_password("ninja"))
