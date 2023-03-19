# k8s

## Notes of Interest

These are quirks in the setup that weren't resolved by a script interacting with k8s or a k8s resource.

---

Issue: create watcher: too many open files

Resolution: Set fs.inotify.max_user_instances=512 in /etc/sysctl.conf (default is 128).