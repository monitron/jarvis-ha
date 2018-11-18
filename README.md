jarvis-ha
=========

This is the home automation software I use personally. It may or may not be
of interest to anyone else.

Requirements
------------

* Node.js Carbon LTS (I'm using 8.12.0)

How to run
----------

* Take a look at the sample config in ``configuration.yml``
* ``npm install -g grunt coffeescript``
* ``npm install``
* ``grunt``
* ``coffee run.coffee``
* Visit http://localhost:3000/

How to start with an exploratory REPL
-------------------------------------

* ``coffee``
* ``coffee> jarvis = require('./lib/jarvis-ha')``
* ``coffee> server = new jarvis.Server()``
