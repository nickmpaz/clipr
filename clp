#!/usr/bin/env python3

import readline, pathlib, sys, os
from os.path import expanduser

DIR_NAME = expanduser("~") + "/.clipr/"
FILE_NAME = "clipr.txt"
TEMP_NAME = "tmp.txt"

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

    clp            |    retrieve a value to clipboard
    clp store      |    store a key value pair
    clp rm         |    remove a key value pair
    clp list       |    list all keys
    clp update     |    update clipr
    clp help       |    help 
    clp install    |    install clipr

    """
    print(help_message)
    sys.exit()

def store():

    key_store = input("key to store: ")
    #FIXME check key is not more thana word. check not doble
    value_store = input("value to store: ")
    with open(DIR_NAME + FILE_NAME, "a+") as text_file:
        text_file.write(key_store + " " + value_store + "\n")

    print("added key: " + key_store)
    sys.exit()
    

def remove():
    keys = {}
    try:
        with open(DIR_NAME + FILE_NAME, "r+") as f:
            content = f.readlines()
        for c in content:
            try:
                key = c.split(' ', 1)[0]
                value = c.split(' ', 1)[1]
                keys[key] = value
            except: 
                pass
    except:
        pass

    # set auto-completer
    completer = MyCompleter(list(keys.keys()))
    readline.set_completer(completer.complete)
    readline.parse_and_bind('tab: complete')

    # get input 
    request = input("key to remove: ")

    if request not in keys.keys():
        print("invalid key")
        sys.exit()

    # remove the key
    cmd = "grep -v '^%s\\b' %s | cat > %s" % (request, DIR_NAME+FILE_NAME, DIR_NAME+TEMP_NAME)
    os.system(cmd)
    cmd = "cat %s > %s" % (DIR_NAME+TEMP_NAME, DIR_NAME+FILE_NAME)
    os.system(cmd)
    cmd = "rm %s" % (DIR_NAME+TEMP_NAME)
    os.system(cmd)
    print("removed key: " + request)
    sys.exit()

def list_keys():
    cmd = "grep -o '^\w*\\b' %s%s | cat" % (DIR_NAME, FILE_NAME)
    os.system(cmd)
    sys.exit()

def update():
    print("update")

def retrieve():
    
    keys = {}
    try:
        with open(DIR_NAME + FILE_NAME, "r+") as f:
            content = f.readlines()
        for c in content:
            try:
                key = c.split(' ', 1)[0]
                value = c.split(' ', 1)[1]
                keys[key] = value
            except: 
                pass
    except:
        pass

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

# ===== ===== ===== #

args = sys.argv
args.pop(0)

if len(args) > 0:

    if args[0] == 'help' or args[0] == '-h' or args[0] == '--help':
        help_message()

    elif args[0] == 'store':
        store()

    elif args[0] == 'rm':
        remove()

    elif args[0] == 'update':
        update()
        
    elif args[0] == 'list':
        list_keys()

    elif args[0] == 'install-l':
        install_l()

    elif args[0] == 'install-m':
        install_m()

else:

    retrieve()







