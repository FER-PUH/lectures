## REPL
Use `cabal repl` to easily play around and test your functions. Functions from
`Main` (the main module) can be exucted right away, while functions from other
modules need to be imported first:

```
$ cabal repl
ghci> executeDirectCommand ....
ghci> import Core
ghci> deposit ...
```

## Running the app
You can run your app with `cabal run`.
```
$ cabal run bank deposit petar 200
petar deposited 200
$ cabal run bank withdraw marko 100
marko withdrew 100
$ cabal run bank accounts
... account table output ...
$ cabal run bank serve
Setting phasers to stun... (port 3000) (ctrl-c to quit)
```
You can switch the port to the default HTTP port (80), but that will force you
to run the app as root/admin.

Use the browser or curl to communicate with the server over HTTP:
```bash
curl 'localhost:3000/deposit?name=marko&amount=100'
curl 'localhost:3000/withdraw?name=marko&amount=50'
curl 'localhost:3000/balance?name=marko'
```

## Building the binary
You can create a binary of your app with `cabal install`.
```bash
cabal install --installdir=. --install-method=copy --overwrite-policy=always
```
This will create a deployable binary in the project directory. You can then
run/deploy this binary from whereever you want:
```
$ ./bank deposit petar 200
petar deposited 200
$ ./bank withdraw marko 100
marko withdrew 100
$ ./bank accounts
... account table output ...
$ ./bank serve
Setting phasers to stun... (port 3000) (ctrl-c to quit)
```

## Other useful commands
### The `scp` command
You can copy your binary to a server using `scp`:
```bash
scp ./bin/bank username@server_ip_or_domain:/path/on/server
```

### The `watch` command
You can get a "live feed" of all balances with the `watch` command. Running
`watch` with `-n 1` runs the `bank accounts` command and prints the
result every second.

```bash
# You can use it both with cabal run...
watch -n 1 cabal run bank accounts
# ... And with the built binary
watch -n 1 ./bank accounts
```

