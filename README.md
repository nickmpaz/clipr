# Clipr

## Automate your Copy-and-Paste Workflow

Demo: https://youtu.be/5Jfa-uHwWxE

Clipr is a simple command line tool for those who find themselves 
copy-and-pasting the same things over and over.

- store easy to remember keys with hard to remember values
- look up a key quickly with tab auto-complete
- Clipr copies the key to your primary selection, and the value to clipboard

Never spend time searching documentation to copy text again! Great for:

- usernames and passwords
- api keys and tokens
- boilerplate code
- etc

## Prerequisites

Clipr requires xclip, a command line interface to X selections. Check that 
it's installed with:
    
    $ xclip -version

Or install with your operating system's package manager. For example:

    $ sudo apt install xclip

## Install

    $ git clone http://github.com/nickmpaz/clipr.git && cd clipr
    $ sudo ln -s $(pwd)/clp /usr/local/bin/

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


