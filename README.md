# Clipr

A simple command line tool for those who find themselves copying and pasting
the same things over and over:
- use Clipr to store key-value pairs
- look up a key easily with tab auto-complete
- Clipr will automatically copy it's value to clipboard

## Prerequisites

Clipr requires xclip, a command line interface to X selections. Check it's
installed with:
    
    $ xclip -version

Or install with your operating system's package manager. For example:

    $ sudo apt install xclip

## Install on Linux

    $ git clone http://github.com/nickmpaz/clipr.git && cd clipr
    $ ./clp install-l && . ~/.bashrc

## Install on MacOS
 
    $ git clone http://github.com/nickmpaz/clipr.git && cd clipr
    $ ./clp install-m && . ~/.bash_profile

## Help

    $ clp help
    
    [ clipr ]

    clp            |    retrieve a value to clipboard
    clp add        |    store a key value pair
    clp rm         |    remove a key value pair
    clp ls         |    list all keys
    clp update     |    update clipr
    clp help       |    help



