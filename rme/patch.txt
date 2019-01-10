26-Apr-13
$ ls
main.c main.c.orig

$ diff -u main.c main.c.orig >mainpatch.diff

---

22-Apr-13

$ ls
pristine/   whatif/

$ diff -ur pristine whatif >patchpris.diff

$ patch -i patchpris.diff

...manual prompts...

...or maybe...

$ ls 
gc-7.2/

$ patch -p1 -i patchpris.diff
