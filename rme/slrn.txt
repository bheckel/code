Get this error during compile (after compiling slang OOTB):
/home/bqh0/src/slang-1.4.5/src/slimport.c:135: undefined reference to `dlerror'

Solved the problem by appending "-ldl" to the LIBS setting of src/Makefile

Must create ~/slrn
~/slrn/news.cis.dfn.de
~/slrn/news.gmane.org
Then do symlink from ~/.slrnrc to each ~/slrn subdir

Use ~/bin/slrn to run multiple NNTP servers (so that they don't collide with
each other).

---

Refresh newsgroups in slrn
/usr/bin/slrn --create -h news.cis.dfn.de -f /home/rheckel/slrn/news.cis.dfn.de jnewsrc

