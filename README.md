# HUST-OS-Kernel-Contribution

## Introduction

HUST OS Kernel Contribution Team

### Clone This Repository

```
git clone --recurse-submodules git@github.com:hust-open-atom-club/HUST-OS-Kernel-Contribution.git
```

### Testing Kernel with Smatch

Run smatch over linux kernel mainline, linux-next, and openeuler kernel repositories.

```
./update_kernel_repo mainline

./update_kernel_repo linux-next

./update_kernel_repo openeuler
```

If you would like to update smatch, directly `cd` to the smatch folder and do `git pull`.

## References

[1] <https://mudongliang.github.io/2022/03/16/run-smatch-over-mainline-kernel.html>
