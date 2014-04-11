# ActiveWreckered

This project was a coding exercise I undertook in order to gain a better grasp of what happens under the hood in an ORM generally, and in Active Record specifically.

It's an attempt to clone the primary features of ActiveRecord, including:
* Object Persistence
* Mass assignment
* Association methods
* Query methods

## Technical Features

* Heavy use of Ruby metaprogramming
* Templatized SQL queries, with escaping to prevent injection attacks.
* Modular implementation of key features.