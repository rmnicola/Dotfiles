# Configuration steps

## 1. Install system packages

```sh
./rn-install-packages.sh
```

Select only system packages

## 2. Configure rust

```sh
./rn-install-rust.sh
```

## 3. Install rest of packages

```sh
./rn-install-packages.sh
```

Select all packages

## 4. Install dotfiles

* Clone dotfiles repo
* Remove all the directories that are already in ~/.config
* Use rn-install-dotfiles in the Dotfiles repo root

## 5. Configure zsh

* Use rn-configure-zsh script

## 6. Configure tlp

* Use rn-configure-tlp script
* Reboot

## 7. Configure git

* Use rn-generate-ssh-key script
* Use rn-configure-git script
* Paste ssh keys into github/gitlab
