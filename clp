#!/usr/bin/env python3

import readline, pathlib, sys, os
from os.path import expanduser

DIR_NAME = expanduser("~") + "/.clipr/"
FILE_NAME = "clipr.txt"

# make storage file directory if it doesn't exist
pathlib.Path(DIR_NAME).mkdir(parents=True, exist_ok=True) 

class MyCompleter(object):  # Custom completer

    def __init__(self, options):
        self.options = sorted(options)

    def complete(self, text, state):
        if state == 0:  # on first trigger, build possible matches
            if text:  # cache matches (entries that start with entered text)
                self.matches = [s for s in self.options 
                                    if s and s.startswith(text)]
            else:  # no text entered, all matches possible
                self.matches = self.options[:]

        # return match indexed by state
        try: 
            return self.matches[state]
        except IndexError:
            return None

def help_message():
    help_message = r"""
    [ clipr ] 

    clp            |    retrieve a value to clipboard
    clp add        |    store a key value pair
    clp rm         |    remove a key value pair
    clp ls         |    list all keys
    clp update     |    update clipr
    clp install    |    install clipr
    clp help       |    help 

    """
    print(help_message)
    sys.exit()

def store():

    key_store = input("key to store: ")
    value_store = input("value to store: ")
    keys = read_to_dict()
    keys[key_store] = value_store
    
    write_to_file(keys)

    print("added key: " + key_store)
    sys.exit()
    

def remove():

    keys = read_to_dict()

    # set auto-completer
    completer = MyCompleter(list(keys.keys()))
    readline.set_completer(completer.complete)
    readline.parse_and_bind('tab: complete')

    # get input 
    request = input("key to remove: ")

    if request not in keys.keys():
        print("invalid key")
        sys.exit()

    keys.pop(request)
    write_to_file(keys)
    
    print("removed key: " + request)
    sys.exit()

def list_keys():

    keys = read_to_dict()
    print("key".rjust(36) + " -> " + "value")
    print(("_" * 26).center(76) + "\n")
    for key in sorted(keys.keys()):
        print(key.rjust(36) + " -> " + keys[key])
    sys.exit()

def update():
    
    pathname = os.path.dirname(__file__)
    update = ("cd %s && git status") % (pathname)
    os.system(update)

def retrieve():
    
    keys = read_to_dict()

    # set auto-completer
    completer = MyCompleter(list(keys.keys()))
    readline.set_completer(completer.complete)
    readline.parse_and_bind('tab: complete')

    # get input 
    request = input("enter a key: ")

    if request not in keys.keys():
        print("invalid key")
        sys.exit()

    # copy matching value to clipboard
    key_value = keys[request].strip()
    cmd = 'printf "%s" | xclip -selection "clipboard"' % (key_value)
    message = 'copied to clipboard: %s' % (key_value)

    print(message)
    os.system(cmd)
    sys.exit()

def install_l():
    cmd = "echo 'export PATH=$PATH:'`pwd` >> ~/.bashrc"
    os.system(cmd)
    
def install_m():
    cmd = "echo 'export PATH=$PATH:'`pwd` >> ~/.bash_profile"
    os.system(cmd)

def read_to_dict():
    keys = {}
    try:
        with open(DIR_NAME + FILE_NAME, "r+") as f:
            content = f.readlines()
        for c in content:
            try:
                key = c.split(' ', 1)[0]
                value = c.split(' ', 1)[1]
                keys[key.strip()] = value.strip()
            except: 
                pass
    except:
        pass
    return keys

def write_to_file(keys):
    with open(DIR_NAME + FILE_NAME, "w") as text_file:
        for key in sorted(keys):
            text_file.write(key + " " + keys[key] + "\n")


# ===== ===== ===== #

args = sys.argv
args.pop(0)

if len(args) > 0:

    if args[0] == 'add':
        store()

    elif args[0] == 'rm':
        remove()

    elif args[0] == 'update':
        update()
        
    elif args[0] == 'ls':
        list_keys()

    elif args[0] == 'install-l':
        install_l()

    elif args[0] == 'install-m':
        install_m()

    else:
        help_message()

else:

    retrieve()







