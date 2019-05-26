#!/usr/bin/env python3

import pathlib, sys, subprocess, os, curses, time, inspect, json, re, os.path, getpass
from os.path import expanduser

DIR_NAME = expanduser("~") + "/.clipr/"
PLAIN_TEXT = "clipr-plain.txt"
ENCRYPTED_TEXT = "clipr-encrypted.txt"
ROWS, COLUMNS = os.popen('stty size', 'r').read().split()
LS_WIDTH = int(COLUMNS)
LS_DIVIDER = '  --->  '
LS_LEFT = (LS_WIDTH // 3) - (len(LS_DIVIDER) // 2)
LS_RIGHT = LS_WIDTH - LS_LEFT - len(LS_DIVIDER)
BACKSPACE = 'KEY_BACKSPACE'
TAB = '\t'
ENTER = '\n'
RETRIEVE = "retrieve key: "
REMOVE = "remove key: "
KEY_ADD = "key to add: "
VALUE_ADD = "value to add: "
KEY_INVALID = "error: keys must not contain spaces"
KEY_NOT_FOUND = "error: key not found"
KEY_ADDED = "added key: "
KEY_REMOVED = "removed key: "
ADD_END = "DONE"
VALUE_ADD_LONG = "value to add (enter '%s' to submit): " % (ADD_END)
KEY_COPIED = "[ COPIED TO PRIMARY ]".center(LS_WIDTH, '-') + "\n\n"
VALUE_COPIED = "\n" + "[ COPIED TO CLIPBOARD ]".center(LS_WIDTH, "-") + "\n\n%s\n\n" + "-" * LS_WIDTH
ENCRYPT_CMD = "printf '%%s' '%s' | gpg -ca --batch --passphrase %s > " + DIR_NAME + ENCRYPTED_TEXT
DECRYPT_CMD = 'cat ' + DIR_NAME + ENCRYPTED_TEXT + ' | gpg -daq --batch --passphrase %s'
PASSWORD = "password: "
SET_PASSWORD = "set password: "
CONFIRM = "confirm password: "
BAD_PASSWORD = "incorrect password"
RESET_CONFIRM = "reset keys? [y/N]: "
RESET = "keys have been reset"
HELP_MESSAGE = r"""
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
    """

# make storage file directory if it doesn't exist
pathlib.Path(DIR_NAME).mkdir(parents=True, exist_ok=True)     

def add(keys):
    key_store = input(KEY_ADD) 
    if (len(key_store.split()) > 1):
        print(KEY_INVALID)
        return add(keys)
    value_store = input(VALUE_ADD)
    keys[key_store] = value_store
    return key_store, keys

def add_long(keys):
    key_store = input(KEY_ADD) 
    if (len(key_store.split()) > 1):
        print(KEY_INVALID)
        return add_long(keys)
    print(VALUE_ADD_LONG)
    value_store = input()
    while True:
        current_line = input()
        if current_line == ADD_END:
            break
        value_store = value_store + "\n" + current_line

    keys[key_store] = value_store
    return key_store, keys

def list_keys(keys):
    print("-" * LS_WIDTH + "\n")
    print("key".rjust(LS_LEFT) + LS_DIVIDER + "value\n")
    print("-" * LS_WIDTH + "\n")
    for key in sorted(keys.keys()):
        print(key[0:LS_LEFT].rjust(LS_LEFT) + LS_DIVIDER + repr(keys[key])[1:LS_RIGHT])
    print("\n" + "-" * LS_WIDTH + "\n")

def retrieve(keys, prompt):

    key_list = sorted(keys.keys())        
    possible_keys = key_list
    query = ""
    tab_string = ""

    try:

        win = curses_setup()
        win.addstr(prompt)
        for key in key_list:
            win.addstr('\n' + " " * len(prompt) + key)

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
                    win.addstr(0,0,prompt)
                    win.addstr(query, curses.A_STANDOUT)
                    win.refresh()
                    time.sleep(0.1)
                    win.addstr(0,0,prompt + query)
                    win.refresh()
                    continue
            else:
                query += ch

            win.clear()
            win.addstr(prompt + query)
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
                    win.addstr('\n' + " " * len(prompt) + key)

            if not first_iter:
                possible_keys = new_possible_keys

            win.addstr(0, len(prompt + query), tab_string[len(query):], curses.A_STANDOUT)

    except:
        curses_cleanup()
        raise

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

def reset_encryption():
    password = getpass.getpass(SET_PASSWORD)
    confirm = getpass.getpass(CONFIRM)
    if password != confirm:
        return reset_encryption()
    message = "{}"
    proc = subprocess.run(
        ENCRYPT_CMD % (message, password), 
        stdout=subprocess.PIPE, 
        stderr=subprocess.PIPE,
        shell=True
    )
    return password

def pass_handler():
    exists = os.path.isfile(DIR_NAME + ENCRYPTED_TEXT)
    if not exists: return reset_encryption()
    else: return getpass.getpass(PASSWORD)

def read_to_dict(encrypted, password=None):
    if encrypted:
        try:
            proc = subprocess.run(
                DECRYPT_CMD % password, 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE,
                shell=True
            )
            proc.check_returncode()
            return json.loads(proc.stdout)

        except subprocess.CalledProcessError as e:
            print(BAD_PASSWORD)
            sys.exit()

    else:
        try:
            with open(DIR_NAME + PLAIN_TEXT, "r+") as f:
                keys = json.load(f)
    
        except:
            pass
        return keys

def write_to_file(keys, encrypted, password=None):
    if encrypted:

        message = json.dumps(keys)
        proc = subprocess.run(
            ENCRYPT_CMD % (message, password), 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE,
            shell=True
        )
    else:
        with open(DIR_NAME + PLAIN_TEXT, "w") as text_file:
            text_file.write(json.dumps(keys))

def copy_to_primary(copystr): os.system("printf '%%s' \"%s\" | xclip" % (copystr.replace('"', '\\"')))

def copy_to_clipboard(copystr): os.system("printf '%%s' \"%s\" | xclip -selection \"clipboard\"" % (copystr.replace('"', '\\"')))

def echo(string): os.system("printf '%%s\n' \"%s\"" % (string.replace('"','\\"')))

def reset_plain(): os.system('printf "{}" > ' + DIR_NAME + PLAIN_TEXT)

def reset(encrypted):
    if input(RESET_CONFIRM).lower() not in ['yes', 'y']: sys.exit()
    if encrypted: reset_encryption()
    else: reset_plain()
    print(RESET)

def update(): os.system(("cd %s && git reset --hard && git pull origin master") % (os.path.dirname(os.path.realpath(__file__))))

def uninstall(): os.system("rm -r %s && rm -rf %s" % (DIR_NAME, os.path.dirname(os.path.realpath(__file__))))

# ===== # ===== # ===== #
try:

    args = " ".join(sys.argv[1:])

    if args == "":
        keys = read_to_dict(encrypted=False)
        key, value = retrieve(keys, RETRIEVE)
        print(KEY_COPIED + key)
        echo(VALUE_COPIED % value)
        copy_to_primary(key)
        copy_to_clipboard(value)

    elif args == "reset": 
        reset(encrypted=False)

    elif args == "add": 
        keys = read_to_dict(encrypted=False)   
        key_added, keys = add(keys)
        write_to_file(keys, encrypted=False)
        print(KEY_ADDED + key_added)

    elif args == "add-long": 
        keys = read_to_dict(encrypted=False)
        key_added, keys = add_long(keys)
        write_to_file(keys, encrypted=False)
        print(KEY_ADDED + key_added)

    elif args == "rm":
        keys = read_to_dict(encrypted=False)
        key, value = retrieve(keys, REMOVE)
        keys.pop(key)
        write_to_file(keys, encrypted=False)
        print(KEY_REMOVED + key)

    elif args == "ls": 
        keys = read_to_dict(encrypted=False)
        list_keys(keys)

    elif args == "secret": 
        password = pass_handler()
        keys = read_to_dict(encrypted=True, password=password)
        key, value = retrieve(keys, RETRIEVE)
        print(KEY_COPIED + key)
        echo(VALUE_COPIED % value)
        copy_to_primary(key)
        copy_to_clipboard(value)

    elif args == "secret reset": 
        reset(encrypted=True)

    elif args == "secret add": 
        password = pass_handler()
        keys = read_to_dict(encrypted=True, password=password)   
        key_added, keys = add(keys)
        write_to_file(keys, encrypted=True, password=password)
        print(KEY_ADDED + key_added)

    elif args == "secret add-long": 
        password = pass_handler()
        keys = read_to_dict(encrypted=True, password=password)
        key_added, keys = add_long(keys)
        write_to_file(keys, encrypted=True, password=password)
        print(KEY_ADDED + key_added)

    elif args == "secret rm": 
        password = pass_handler()
        keys = read_to_dict(encrypted=True, password=password)
        key, value = retrieve(keys, REMOVE)
        keys.pop(key)
        write_to_file(keys, encrypted=True, password=password)
        print(KEY_REMOVED + key)

    elif args == "secret ls": 
        password = pass_handler()
        keys = read_to_dict(encrypted=True, password=password)
        list_keys(keys)

    elif args == "uninstall": uninstall()

    elif args == "update": update()

    else: print(HELP_MESSAGE)  

except KeyboardInterrupt:
    print()
    sys.exit()





    

    






