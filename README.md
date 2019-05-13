# Clipr

## Automate your Copy-and-Paste Workflow

Clipr is a simple command line tool for those who find themselves 
copy-and-pasting the same things over and over.

- use Clipr to store key-value pairs
- look up a key easily with tab auto-complete
- Clipr copies the key to your primary selection, and the value to clipboard

Never spend time searching documentation to copy text again!

## Prerequisites

Clipr requires xclip, a command line interface to X selections. Check that 
it's installed with:
    
    $ xclip -version

Or install with your operating system's package manager. For example:

    $ sudo apt install xclip

## Install

    $ git clone http://github.com/nickmpaz/clipr.git && cd clipr
    $ sudo ln -s $(pwd)/clipr /usr/local/bin/

## Uninstall 

    $ clp uninstall
    $ sudo rm /usr/local/bin/clp
    

## Help

    $ clp help
    
    [ clipr ] 

    clp             |    retrieve a key-value pair
    clp add         |    store a key-value pair
    clp add-long    |    for multi-line values
    clp rm          |    remove a key-value pair
    clp ls          |    list all keys
    clp update      |    update clipr
    clp help        |    help 

    https://github.com/nickmpaz/clipr


