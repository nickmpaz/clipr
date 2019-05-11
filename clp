#!/usr/bin/env python3

import readline, pathlib, sys, os, curses
from os.path import expanduser

DIR_NAME = expanduser("~") + "/.clipr/"
FILE_NAME = "clipr.txt"

KEY_ADD = "key to add: "
VALUE_ADD = "value to add: "
KEY_INVALID = "error: keys must not contain spaces"
KEY_NOT_FOUND = "error: key not found"
KEY_ADDED = "added key: "
KEY_REMOVED = "removed key: "
ADD_END = "DONE"
VALUE_ADD_LONG = "value to add (enter '%s' to submit): " % (ADD_END)
KEY_COPIED = "key -> primary: "
VALUE_COPIED = "value -> clipboard: "

BACKSPACE = 'KEY_BACKSPACE'
TAB = '\t'
ENTER = '\n'

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

    key_store = input(KEY_ADD) 
    if (len(key_store.split()) > 1):
        print(KEY_INVALID)
        store()
    value_store = encode(input(VALUE_ADD))
    keys = read_to_dict()
    keys[key_store] = value_store
    write_to_file(keys)

    print(KEY_ADDED + key_store)
    sys.exit()

def add_long():
    key_store = input(KEY_ADD) 
    if (len(key_store.split()) > 1):
        print(KEY_INVALID)
        add_long()

    print(VALUE_ADD_LONG)
    current_line = ""
    value_store = input()
    while True:
        current_line = encode(input())
        if current_line == ADD_END:
            break
        value_store = value_store + "\\n" + current_line
    keys = read_to_dict()
    keys[key_store] = value_store
    print(keys[key_store])

    write_to_file(keys)

    print(KEY_ADDED + key_store)
    sys.exit()

def list_keys():

    keys = read_to_dict()
    print("key".rjust(36) + " -> " + "value")
    print(("_" * 26).center(76) + "\n")
    for key in sorted(keys.keys()):
        print(key[0:36].rjust(36) + " -> " + keys[key][0:36])
    sys.exit()

def retrieve():

    keys = read_to_dict()
    key_list = sorted(keys.keys())        
    possible_keys = key_list
    query = ""
    tab_string = ""

    try:

        # set up curses and initial window
        win = curses_setup()
        win.addstr('key:')
        for key in key_list:
            win.addstr('\n     ' + key)

        while True:

            ch = win.getkey()

            if ch == ENTER:
                if query in possible_keys:
                    curses_cleanup()
                    return query, keys[query]
                else:
                    query = ""
                    tab_string = ""
                    possible_keys = key_list
            elif ch == BACKSPACE:
                query = query[:-1]
                possible_keys = key_list
            elif ch == TAB:
                query = tab_string
            else:
                query += ch

            win.clear()
            win.addstr('key: ' + query)
            # ====== vvvvvvv ======
            new_possible_keys = []
            tab_string = query

            first_iter = True
            for key in possible_keys:
                if key.startswith(query):
                    if first_iter:
                        tab_string = key
                        first_iter = False
                    else:
                        tab_string = common_start(tab_string, key)
                    new_possible_keys.append(key)                    
                    win.addstr('\n     ' + key)

            if not first_iter:
                possible_keys = new_possible_keys
    except KeyboardInterrupt:
        curses_cleanup()
        sys.exit()
    except:
        pass
    finally:
        curses_cleanup()

def curses_setup():
    win = curses.initscr()
    curses.noecho()
    win.keypad(True)
    curses.curs_set(False)
    return win

def curses_cleanup():
    curses.echo()
    curses.endwin()

def common_start(sa, sb):
    def _iter():
        for a, b in zip(sa, sb):
            if a == b:
                yield a
            else:
                return
    return ''.join(_iter())

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

def encode(enc_str): return enc_str.replace('\t',' ' * 4).replace('\"', '\\"')

def copy_to_primary(copystr): os.system('printf "%s" | xclip' % (copystr))

def copy_to_clipboard(copystr): os.system('printf "%s" | xclip -selection "clipboard"' % (copystr))

def clear(): os.system('> ' + DIR_NAME + FILE_NAME)

def update(): os.system(("cd %s && git reset --hard && git pull origin master") % (os.path.dirname(__file__)))

def install_l(): os.system("echo 'export PATH=$PATH:'`pwd` >> ~/.bashrc")
    
def install_m(): os.system("echo 'export PATH=$PATH:'`pwd` >> ~/.bash_profile")

# ===== ===== ===== #

args = sys.argv
args.pop(0)

if len(args) > 0:

    if args[0] == 'add':
        store()

    elif args[0] == 'add-long':
        add_long()

    elif args[0] == 'rm':
        key, value = retrieve()
        keys = read_to_dict()
        keys.pop(key)
        print(KEY_REMOVED + key)
        write_to_file(keys)

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

    key, value = retrieve()
    print(KEY_COPIED + key)
    print(VALUE_COPIED + value)
    copy_to_primary(key)
    copy_to_clipboard(value)
    






