Thor Plugins
============

They're plugins! For Thor! They do things!

Autopuppet
----------

    thor puppet:agent [HOST]   # Update the server and run puppet on a host
    thor puppet:config         # Generate your ~/.autopuppet
    thor puppet:deploy         # Run puppet deployment on master
    thor puppet:hotrun [HOST]  # Deploy changes and run agent updates

genpass
-------

    thor gen:pass SIZE    # Create a password with SIZE characters, defaults to 8
    thor gen:phrase SIZE  # Create a passphrase with SIZE words, defaults to 5
