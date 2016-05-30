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

* Take a look at the dummy config in ``lib/Server.coffee``
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

Fun Times
---------

coffee-script 1.7+ breaks vows 0.7.0 -- https://github.com/flatiron/vows/pull/297