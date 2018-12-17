nerdCH
======
The Purpose of this README
--------------------------
CommandHelper generates a number of default configurations in
`plugins/CommandHelper/` when the plugin first starts up:

 * `aliases.msa`
 * `main.ms`
 * `auto_include.ms`
 * `prefs/preferences.ini`
 * `prefs/persistence.ini`

Historically, we've been a bit liberal in how we modify the first three of these
files, adding custom code to them at random, such that it is very difficult to
identify common configuration between servers because of the sheer volume of
code to compare. However, we have been gradually moving aliases and functions
into shared folders under `plugins/CommandHelper/LocalPackages/`, such that we
now have a fairly minimal configuration of these files, with common code mostly
shared between Minecraft servers.

The purpose of this README is to codify a NerdNu standard for CommandHelper
configuration so as to solidify the gains we have made in keeping the
configuration minimal and comprehensible.


Installing CommandHelper the NerdNu Way
---------------------------------------
### Repository on Disk

The nerdCH repository is cloned to `~/shared/NerdCH` (it seems we can't resist
fiddling with things even when it's pointless):
```
git clone https://github.com/NerdNu/nerdCH NerdCH
```


### Local Packages

CommandHelper packages from the `LocalPackages/` folder of the repository on
disk are symlinked into the `LocalPackages/` directory of the servers.

For example:
```
cd plugins/CommandHelper/LocalPackages/
ln -fs ~/shared/NerdCH/global .
```

### Configuration Files

 * `prefs/preferences.ini` - Set `show-splash-screen=false` obviously.
   Historically, we also used to set `script-name=config.txt`, but that is
   silly and confusing. We now keep the default setting, `script-name=aliases.msa`.
 * `auto_include.ms` - This is shared between all servers:
```
cd plugins/CommandHelper
rm auto_include.ms
ln -fs ~/shared/NerdCH/auto_include.ms .    
```
 * `aliases.msa` and `main.ms` - These are symlinked into the CommandHelper
   directory, e.g. for PvE:
```
cd /ssd/pve/plugins/CommandHelper
rm aliases.msa
rm main.ms
ln -fs ~/shared/NerdCH/pve/aliases.msa .
ln -fs ~/shared/NerdCH/pve/main.ms .
```


### Guidance on the Contents of aliases.msa, main.ms, auto_include.ms

Ideally, these files should be as small as possible. We would like to have as
much of our code under LocalPackages as possible, so that we only have a single
version of each command or function, shared between multiple servers.

The only reasons to put things in these files are:

 * The code defines a global configuratiojn variable, consulted in various CH
   aliases and functions, e.g. `export('sharedata.source', 'pve')` in `pve/main.ms`, or
 * A CH alias or function accesses a configuration file in `plugins/CommandHelper/`.
   The CH `read()` function always reads files relative to the currently
   executing code. An example would be the `_kit()` function in [auto_include.ms](https://github.com/NerdNu/nerdCH/blob/master/auto_include.ms).


### Server-Specific Packages

Historically, server-specific packages (e.g. `LocalPackages/pve-only`) have been
kept in the main `LocalPackages` directory and individual packages symlinked into
place for each server, i.e.
```
cd ~/servers/pve-dev/plugins/CommandHelper/LocalPackages
ln -fs ~/shared/NerdCH/LocalPackages/dynmap .
ln -fs ~/shared/NerdCH/LocalPackages/global .
...

```
It makes more sense from a practicality standpoint to isolate server-specific
packages away from the `LocalPackages` directory so that one may then simply
symlink the entire directory into place, followed by a server-specific package
if applicable, i.e.
```
cd ~/servers/pve-dev/plugins/CommandHelper
ln -fs ~/shared/NerdCH/LocalPackages .
ln -fs ~/shared/NerdCH/pve/pve-only .
```
