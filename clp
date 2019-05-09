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

    clp             |    retrieve a value to clipboard
    clp add         |    store a key value pair
    clp add-long    |    for multi-line values
    clp rm          |    remove a key value pair
    clp ls          |    list all keys
    clp update      |    update clipr
    clp help        |    help 

    """
    print(help_message)
    sys.exit()

def store():

    key_store = input("key to store: ") 
    if (len(key_store.split()) > 1):
        print("please enter a one word key")
        store()
    value_store = encode(input('value to store:'))
    keys = read_to_dict()
    keys[key_store] = value_store
    write_to_file(keys)

    print("added key: " + key_store)
    sys.exit()

def add_long():
    key_store = input("key to store: ") 
    if (len(key_store.split()) > 1):
        print("please enter a one word key")
        add_long()

    print('value to store:')
    current_line = ""
    value_store = input()
    while True:
        current_line = encode(input())
        if current_line == "DONE":
            break
        value_store = value_store + "\\n" + current_line
    keys = read_to_dict()
    keys[key_store] = value_store
    print(keys[key_store])

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
        print(key[0:36].rjust(36) + " -> " + keys[key][0:36])
    sys.exit()

def update():
    
    pathname = os.path.dirname(__file__)
    update = ("cd %s && git reset --hard && git pull origin master") % (pathname)
    os.system(update)
    sys.exit()

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
        retrieve()

    # copy matching value to clipboard
    key_value = keys[request]
    cmd = 'printf "%s" | xclip -selection "clipboard"' % (key_value)
    cmdtest = 'printf "%s"' % (key_value)
    message = 'copied to clipboard: %s' % (key_value)
    os.system(cmdtest)
    os.system(cmd)
    sys.exit()

def encode(enc_str):
    enc_str = enc_str.replace('\t',' ' * 4)
    enc_str = enc_str.replace('\"', '\\"')
    return enc_str

def clear():
    os.system('> ' + DIR_NAME + FILE_NAME)

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

    elif args[0] == 'add-long':
        add_long()

    elif args[0] == 'rm':
        remove()

    elif args[0] == 'update':
        update()
        
    elif args[0] == 'ls':
        list_keys()

    elif args[0] == 'clear':
        clear()

    elif args[0] == 'install-l':
        install_l()

    elif args[0] == 'install-m':
        install_m()

    else:
        help_message()

else:

    retrieve()







