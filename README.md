# Clipr

## Automate your Copy-and-Paste Workflow

Demo: https://youtu.be/5Jfa-uHwWxE

Clipr is a simple command line tool for those who find themselves 
copy-and-pasting the same things over and over.
- store easy to remember keys with hard to remember values
- look up a key quickly with tab auto-complete
- Clipr copies the key to your primary selection, and the value to clipboard

Key-value pairs can be stored as plain text for convenience, or as pgp encrypted 
text for security. Never spend time searching documentation to copy text again! 
Great for:
- usernames and passwords
- api keys and tokens
- frequently created files
- boilerplate code
- etc

## Prerequisites

Clipr requires:
- xclip: a command line interface to X selections
- GnuPG: a PGP encryption and signing tool

Check that they're installed with:
    
    $ xclip -version
    $ gpg --version

Or install with your operating system's package manager:

    $ sudo apt install xclip
    $ sudo apt install gpg

## Install

    $ git clone http://github.com/nickmpaz/clipr.git && cd clipr
    $ sudo ln -s $(pwd)/clp /usr/local/bin/

## Uninstall 

    $ clp uninstall
    $ sudo rm /usr/local/bin/clp
    

## Help

    $ clp help
    
    [ clipr ] [ https://github.com/nickmpaz/clipr ]
    ______________________________________________________________
                            |
    clp                     |     retrieve a key-value pair
    clp add                 |     store a key-value pair
    clp add-long            |     for multi-line values
    clp rm                  |     remove a key-value pair
    clp ls                  |     list all keys
    clp reset               |     reset keys
                            |
    clp secret              |     retrieve a secret key-value pair
    clp secret add          |     store a secret key-value pair
    clp secret add-long     |     for multi-line values
    clp secret rm           |     remove a secret key-value pair
    clp secret ls           |     list all secret keys
    clp secret reset        |     reset secret password & keys
                            |
    clp update              |     update clipr
    clp help                |     help 
    _____________________________________________________________


