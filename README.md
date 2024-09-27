# dot

Zigit's dotfiles.

It may contains some unpleasant things :/

# mois

The dotfile manager I called 'mois' is from the GNU's stow, but different from
 stow, the mois use normal copy instead of symbolic links, I'm not very satisfy
 with it, therefore naive tool mois was born.

For visiting the difference from system, and apply them:

```bash
./mois status
./mois apply
# REALLY
./mois apply --do
```

The mois contains two parts, 'package' part for what the configurations made to
 it, and 'machine' part for what packages you're going to assemble them.

The 'package' part's directory structure is maintained as:

```bash
stow/
  my_package_a
  my_package_b
  ...
super/
  my_package_a/
    dot-config/
      config.yaml
    dot-local/
      bin/
        wrapper.sh
  my_package_b/
    dot-config.yaml
  ...
```

For each package you should create a "metadata" for it in 'stow', even just
 'touch stow/my_package_a', currently mois relies on the files in the 'stow' as
 the index for packages.

And the machine part is a combination of packages, visit the 'machine' directory
 if you're instrested in.

# git-crypt

My dotfile surely contains some sensitive contents, that may related to my ssh
 config, or for business workflows. Such files are encrypted via 'git-crypt'.

```bash
# on old machine:
git-crypt export-key /path/to/key

# on new machine:
git-crypt unlock /path/to/key
```

Then do the normal git stuff. Be sure to always check whether files are
 encrypted normally.

# nongit

Third party codes I'm using is all placed into the 'party' directory, without
 the annoying 'git submodule', I'm using a strategy called 'nongit', in the
 'mois' script, it will clone the tip (shallow) of a repo, and remove the '.git'
 directory.

All the third party codes is guaranteed unmodified (except some files are
 removed), and the repo source can be viewed in 'stow' directory. It may
 violates some "copyright" things, but, I don't want to change to the submodule
 for now, the submodule is so hard to use.
