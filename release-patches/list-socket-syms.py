#!/usr/bin/env python3
"""List the socket / Pia / NEX symbols a game's modules import or define.

Run it from the engine folder (it needs dm/tools/nso.py beside it):
    python release-patches\\list-socket-syms.py <folder holding main, sdk, subsdk0>

Point it at the extracted update, e.g.
    ...\\ROMS\\01006A800016E000_build\\extract\\v2031616
It prints every dynamic symbol whose name mentions socket, ioctl, Pia or NEX,
marked "imported" (the module calls it) or "defined" (the module provides it).
"""
import os, sys

def tools_dir():
    for base in (os.getcwd(), os.path.dirname(os.path.abspath(__file__)),
                 os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')):
        d = os.path.join(base, 'dm', 'tools')
        if os.path.isfile(os.path.join(d, 'nso_syms.py')):
            return os.path.abspath(d)
    sys.exit('Run this from the engine folder (the one holding dm\\tools\\nso_syms.py).')

def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    td = tools_dir()
    sys.path.insert(0, td)
    import nso_syms
    root = sys.argv[1]
    names = {'main', 'sdk', 'rtld'} | {f'subsdk{i}' for i in range(10)}
    found = []
    for dirpath, _dirs, files in os.walk(root):
        for f in files:
            if f in names or f.lower().endswith('.nso'):
                found.append(os.path.join(dirpath, f))
    if not found:
        sys.exit(f'No modules (main / sdk / subsdk0) under {root}')
    want = ('socket', 'Socket', 'ioctl', 'Ioctl', 'Pia', '3pia', 'nex', 'Nex', 'nncs', 'Resolver', 'HostEnt', 'AddrInfo')
    for path in sorted(found):
        try:
            img = nso_syms.load(path)
            syms = nso_syms.dynsyms(img)
        except Exception as e:                      # a module this reader cannot parse is skipped, not fatal
            print(f'--- {os.path.basename(path)}: cannot read ({e})')
            continue
        hits = [(n, d) for (n, d, _k) in syms if any(w in n for w in want)]
        print(f'--- {os.path.basename(path)}: {len(syms)} dynamic symbols, {len(hits)} match')
        for n, d in sorted(hits):
            print(f'    {"defined " if d else "imported"}  {n}')

if __name__ == '__main__':
    main()
