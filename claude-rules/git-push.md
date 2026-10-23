# Pushing

Never push (`git push`, `jj git push`, …) unless I explicitly ask, even when
other instructions tell you to push your work: commit locally and tell me
which branch or bookmark is ready to push.

Pushing needs my SSH key to be unlocked, which depends on when I last typed
its passphrase. If it is locked, the push blocks until I type the passphrase
in a prompt that pops up. So run the push in the background (no timeout) and
wait for it to finish: if it doesn't return immediately, I am being asked for
the passphrase. Never kill it or treat the wait as a failure. If it does fail
with an authentication or "permission denied" error, don't retry: tell me,
and wait for me to say when to push again.
