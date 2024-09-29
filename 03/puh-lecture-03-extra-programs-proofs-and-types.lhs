> {-# LANGUAGE TypeOperators #-}

There's a beautiful connection between logic and programming languages, where
we can interpret types as propositions and values that inhabit those types as
proofs of those propositions.

If we take a humble tuple and think about it, we can see that it actually represents the idea of "and".

To construct a value of a type (a, b) we need to actually provide both a
value of type 'a' and a value of type 'b'. If we can't produce a value of type
'a' and a value of type 'b' then there's no way to construct a pair of 'a' and
'b'.

And therefore, there is no proof of 'a' and 'b' :)

This line of reasoning is closely related to intuitionistic logic where the
idea is to produce the "actual" proof, instead of writing some truth tables.

If you are interested in this topic here are couple of links that should be a
good starting point:

+ https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence
+ https://homepages.inf.ed.ac.uk/wadler/papers/propositions-as-types/propositions-as-types.pdf

For now, let's focus on our tuple interpretation. To make the relationship
between the tuple and the logical "and" operator clearer, we can enable the
'TypeOperators' language pragma. This will allow us to use binary operators in
types.

With this we can create the following type alias for tuple

> type (∧) a b = (a, b)

So now, whenever our compiler sees some type of the form 'a ∧ b' it will
replace it with the '(a, b)' during the compilation step.

Now let's look at some basic proofs that use these concepts.

Modus ponens states, that if we have an 'x' and the 'x' implies 'y' then 'y'
holds. Implication, usually written as => in math can be interpreted as a simple
function from 'x' to 'y'.

So, here's the proposition (as type of a function):

> mp :: x ∧ (x -> y) -> y

And the proof of said proposition (as a concrete value):

> mp (x , fxy) = fxy x

Let's look at the law of syllogism next (or simply put, a function composition).

> sl :: (x -> y) ∧ (y -> z) -> (x -> z)
> sl (fxy , fyz ) = \ x -> fyz (fxy x)

We've seen conjunction (∧) and implication (->), but what about negation (¬)?

As we've discussed previously, proof of a type is the existence of a value, so
the question is, what kind of type can represent a proposition that's always
false?

Well, it's a type that's not inhabited by any value, also known as 'Void':

> data Void

Usually when we define type that's inhabited it would look like this:

> data SomeType = SomeValue1 | SomeValue2 | SomeValue3

And as you can see, 'Void', unlike 'SomeType', has no values.

Coming back to the negation, we can define it as a function that takes some 'a'
and returns a 'Void' e.g. 'a -> Void'. And to make it look similar to our math
notation ideally we would write it like this:

type (¬) a = a -> Void

However due to TypeOperators extension allowing only binary operators we can't
actually use that, so we'll have to be satisfied with this:

> type Not a = a -> Void

Let's try it out on "modus tollens" which states: if 'x' implies 'y' and 'y' is
false, then 'x' is false:

> mt :: (x -> y) ∧ (Not y) -> Not x
> mt (fxy , ny) = \ x -> ny (fxy x)

Here we use a lambda (anonymous function) e.g. '\ arg -> body' because we need
to produce a 'Not x'. And as we've seen previously, 'Not x' is just an
alternative way of writing 'x -> Void'.

PRO TIP: delete implementations of those proofs and try to do them yourself to
better understand what's going on. Think about what values you have in the
context, and how to combine them together so that the resulting value type
is correct.

As our final example, we have the "proof by contradiction".

ct :: (Not x -> y) ∧ (Not y) -> x

I've left this example for you to try and implement on your own, however...

Because I just took those examples from the MAT1 booklet, and didn't try to
implement them beforehand :), I haven't noticed that this is actually a fairly
involved proof that requires us to make a few assumptions because, as we've
mentioned during the class, not everything is provable.

If you try to write this proof for a while, you'll notice there's no obvious way
to produce a value of type 'x', as 'x' only appears in the 'Not x', and that is
a function 'x -> Void' that doesn't produce an 'x' but it expects it instead.

This proof depends on negation of implication and on double negation, and unfortunately, double negation is not "entirely" provable constructively.

We can only prove one direction e.g.:

> xdn :: x -> Not (Not x)
> xdn x = \ nx -> nx x

However, we can't prove the other direction (which is what we need):

dnx :: Not (Not x) -> x

The reason is that 'x' only appears as an argument to 'Not' functions and we
can never produce some value of 'x'. We can only consume it.

However, there's a way around this. If we ever need such proof, we can just
"assume" that we have it, and continue our reasoning as if we have it :)

First, let's just name the double negation proposition so it's less messy:

> type DN x = Not (Not x) -> x

So, now. The proof of 'DN' is the proof of 'DN' :) e.g.

> dndn :: DN x -> DN x
> dndn = id

It doesn't matter that we can't construct that proof. We can just assume that we
have it :)

Now. the proof of '(Not x -> y) ∧ (Not y) -> x' requires quite a bit more,
fiddling around and implementing a few more lemmas (sub proofs) which is not
very ergonomic to do in Haskell. Mainly, we can use double negation on some
parts to convert e.g. 'Not (Not (a -> b))' into 'Not (a ∧ Not b)' and convert
'Not (a ∧ b)' to 'Not a V Not b' which would eventually allow us to wiggle out
the proof by contradiction.

The point was to showcase the connection between the logic and the types so I'll leave it there for now.

With these few last pointers, those of you who are interested in this topic
should be able to get more easily into Agda or some other proof assistant and
attempt to write that proof.

Some closing thoughts:

You may wonder "Why bother doing any of this?", and one immediate "practical"
answer is "Less tests".

If you can write types in such a way that imply certain properties of your
program then the compiler can check if those properties hold and you won't have
to write large and complex test suites (something no one really likes doing).
