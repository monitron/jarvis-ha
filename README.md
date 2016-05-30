jarvis-ha
=========

Someday this may be a home automation package.

Right now it is nothing at all.


Requirements
------------

* Node.js 4.4.5 LTS
* An installation of the ``openzwave`` library

How to run
----------

* Take a look at the sample config in ``configuration.yml``
* ``npm install -g grunt coffee-script``
* ``npm install``
* ``grunt``
* ``coffee run.coffee``
* Visit http://localhost:3000/

How to start with an exploratory REPL
-------------------------------------

* ``coffee``
* ``coffee> jarvis = require('./lib/jarvis-ha')``
* ``coffee> server = new jarvis.Server()``
