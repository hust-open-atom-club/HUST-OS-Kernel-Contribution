# HUST-OS-Kernel-Contribution

### Introduction
HUST OS Kernel Contribution Team

### Shared link

https://ixy0caf7465.feishu.cn/base/PjgybjSwfaZn4Cso5Daclfzknng?table=tbl6MOmeeFuw7pYx&view=vew0X24kil

### Testing Kernel with Smatch

Refer to the step-by-step guidance[1] to run smatch over the mainline kernel.

Or directly run the deploy script in the mainline or linux-next to deploy automatically.

```
cd mainline
wget https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/linux-6.3-rc4.tar.gz -O kernel.tar.gz
./deploy_smatch_on_mainline.sh
```

```
# get kernel source code with zip format
git archive --format=zip -o kernel.zip HEAD
cd mainline
./deploy_smatch_on_mainline.sh
```

[1] <https://mudongliang.github.io/2022/03/16/run-smatch-over-mainline-kernel.html>
