#!/usr/bin/env python3

import pathlib, sys, os, curses, time, inspect, os.path
from os.path import expanduser

DIR_NAME = expanduser("~") + "/.clipr/"
FILE_NAME = "clipr.txt"
LS_WIDTH = 80
LS_DIVIDER = ' :: '
HALF_WIDTH = int((LS_WIDTH / 2) - (len(LS_DIVIDER) / 2))

KEY_ADD = "key to add: "
VALUE_ADD = "value to add: "
KEY_INVALID = "error: keys must not contain spaces"
KEY_NOT_FOUND = "error: key not found"
KEY_ADDED = "added key: "
KEY_REMOVED = "removed key: "
ADD_END = "DONE"
VALUE_ADD_LONG = "value to add (enter '%s' to submit): " % (ADD_END)
KEY_COPIED = "[ COPIED TO PRIMARY ]".center(LS_WIDTH, '-') + "\n\n"
VALUE_COPIED = "\n" + "[ COPIED TO CLIPBOARD ]".center(LS_WIDTH, "-") + "\n\n"
VALUE_COPIED_BOTTOM = "\n\n" + "-" * LS_WIDTH

BACKSPACE = 'KEY_BACKSPACE'
TAB = '\t'
ENTER = '\n'

HELP_MESSAGE = r"""
    [ clipr ] https://github.com/nickmpaz/clipr

    clp                     |     retrieve a key-value pair
    clp add                 |     store a key-value pair
    clp add-long            |     for multi-line values
    clp rm                  |     remove a key-value pair
    clp ls                  |     list all keys

    clp secret              |     retrieve a secret key-value pair
    clp secret reset        |     (re)set secret password
    clp secret add          |     store a secret key-value pair
    clp secret add-long     |     for multi-line values
    clp secret rm           |     remove a secret key-value pair
    clp secret ls           |     list all secret keys

    clp update              |     update clipr
    clp help                |     help 

    """

# make storage file directory if it doesn't exist
pathlib.Path(DIR_NAME).mkdir(parents=True, exist_ok=True)     

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
    write_to_file(keys)
    print(KEY_ADDED + key_store)
    sys.exit()

def list_keys():
    
    keys = read_to_dict()
    print("-" * LS_WIDTH + "\n")
    print("key".rjust(HALF_WIDTH) + LS_DIVIDER + "value\n")
    print("-" * LS_WIDTH + "\n")
    for key in sorted(keys.keys()):
        print(key[0:HALF_WIDTH].rjust(HALF_WIDTH) + LS_DIVIDER + keys[key][0:HALF_WIDTH])
    print("\n" + "-" * LS_WIDTH)

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
                if query != tab_string:
                    query = tab_string
                else:
                    # blink the query line
                    win.addstr(0,0,"key: ")
                    win.addstr(0,5, query, curses.A_STANDOUT)
                    win.refresh()
                    time.sleep(0.1)
                    win.addstr(0,0,"key: "+ query)
                    win.refresh()
                    continue
            else:
                query += ch

            win.clear()
            win.addstr('key: ' + query)
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

# ===== # ===== # ===== #

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

def echo(string): os.system('echo "%s"' % (string))

def clear(): os.system('> ' + DIR_NAME + FILE_NAME)

def update(): os.system(("cd %s && git reset --hard && git pull origin master") % (os.path.dirname(os.path.realpath(__file__))))

def uninstall(): os.system("rm -r %s && rm -rf %s" % (DIR_NAME, os.path.dirname(os.path.realpath(__file__))))

def install_l(): os.system("echo 'export PATH=$PATH:'`pwd` >> ~/.bashrc")
    
def install_m(): os.system("echo 'export PATH=$PATH:'`pwd` >> ~/.bash_profile")

# ===== ===== ===== #

args = " ".join(sys.argv[1:])

if args == "":
    key, value = retrieve()
    print(KEY_COPIED + key)
    echo(VALUE_COPIED + value + VALUE_COPIED_BOTTOM)
    copy_to_primary(key)
    copy_to_clipboard(value)
    sys.exit()

elif args == "add": store()

elif args == "add-long": add_long()

elif args == "rm":
    key, value = retrieve()
    keys = read_to_dict()
    keys.pop(key)
    write_to_file(keys)
    print(KEY_REMOVED + key)

elif args == "ls": list_keys()

elif args == "secret": pass

elif args == "secret reset": pass

elif args == "secret add": pass

elif args == "secret add-long": pass 

elif args == "secret rm": pass

elif args == "secret ls": pass

elif args == "install-l": install_l()

elif args == "install-m": install_m

elif args == "uninstall": uninstall()

elif args == "update": update()

elif args == "clear": clear()

else: print(HELP_MESSAGE)  

 





    

    






