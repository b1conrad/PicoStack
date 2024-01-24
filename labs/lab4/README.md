# lab4

This lab states that it doesn't matter "if you use Angular, some other framework, or no framework at all to complete this". 
The important thing is to learn how to use "the Sky Event and Sky Cloud APIs directly." 
In other words, using picos as the "back end" of a web application, the data storage layer.

[Pico Stack](https://PicoStack.org/)
uses picos for the "front end" as well, as shown in a ruleset in this folder.

## webapp.krl

This is an example of a Pico Stack approach to building a web application on top of the rulesets written in lab 3.

### temperature_store

- Lab 3, in step 1, calls for writing this ruleset.
- Step 2 calls for it to define functions `temperatures` and `threshold_violations`.
- Step 3 calls for these to be listed in the `provides` clause of the ruleset.

### use module temperature_store

Because the `temperature_store` ruleset `provides` functions, it can be used as a module.

The `webapp` ruleset takes advantage of this, and layers on a web application.
Once a pico has the `temperature_store` ruleset installed, you can also install `webapp`.

### a channel to use `webapp`

The `webapp` ruleset `shares` its `index` function, so that function  can be called from the outside world.

The pico will need a channel to allow for this, so you'll need to create a channel like the one shown here:

![webappChannel](https://github.com/b1conrad/PicoStack/assets/19273926/a4c9c6d8-f48c-4c64-b263-99a73751f657)

You won't expect the channel to be used to send events to the pico, so its event policy denies everything.
It's query policy needs to allow at least the `index` function, but here we allow any functions it `shares` now or may eventually share.

### a URL to invoke the `index` function

Once you have created the channel, copy its identifier (by double-clicking on it in the developer UI),
and build a URL. It will have this form:

`http://DOMAIN:PORT/sky/cloud/ECI/webapp/index.html`

with the all-caps words replaced by the domain and port where you host your pico, and the event channel identifier (ECI) that you have copied.

When you place your URL in your browser, you'll see the web page, looking something like this:

![webappPage](https://github.com/b1conrad/PicoStack/assets/19273926/3723efa4-b5b4-4f0d-aa93-b1fe1c5bfbe5)
