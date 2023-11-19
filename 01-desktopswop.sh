#!/bin/bash
# /etc/profile.d/01-desktopswop.sh - Per-Desktop Environment gtk-*.0 configs swapping to allow DE-specific GTK configs

newde="$XDG_CURRENT_DESKTOP"
if [ ! -z "$newde" ]; then #Skip execution if the value isn't present
oldde=""
interfacegs="gtk-theme font-name icon-theme cursor-theme cursor-size toolbar-style color-scheme enable-animations scaling-factor text-scaling-factor"
soundgs="theme-name"
mousegs="double-click"
wmgs="button-layout"
# Ensure the config directory for storing last Desktop Environment exists
if [ ! -d "$HOME/.config" ]; then
    mkdir "$HOME/.config" >/dev/null 2>&1
fi
if [ ! -d "$HOME/.config/feren-os" ]; then
    mkdir "$HOME/.config/feren-os" >/dev/null 2>&1
fi
# Get prior Desktop Environment from prior instance's note, if there's one
if [ -f "$HOME/.config/feren-os/lastdesktop" ]; then
    oldde=$(cat "$HOME/.config/feren-os/lastdesktop")
fi
if [ "$newde" != "$oldde" ]; then #Skip migrating configs if we already have the correct ones.

#Note down current Desktop Environment for future instances
echo "$newde" > "$HOME/.config/feren-os/lastdesktop"
if [ ! -z "$oldde" ]; then #Don't continue further if there is no known prior DE


for conffolder in "gtk-3.0" "gtk-4.0"; do
    # Empty DE-specific configurations housing folder for the prior DE
    rm -rf "$HOME/.config/$conffolder-$oldde"
    mkdir "$HOME/.config/$conffolder-$oldde" >/dev/null 2>&1
    # Now move configs from prior DE back to their respective folder for safekeeping
    cd "$HOME/.config/$conffolder"
    #  All folders
    for dir in ./*; do
        if [ -d "$dir" ]; then
            mv -f "$dir" "$HOME/.config/$conffolder-$oldde/$dir" >/dev/null 2>&1
        fi
    done
    #  CSS and config files
    for i in ./*.css; do
        mv -f "$i" "$HOME/.config/$conffolder-$oldde/$i" >/dev/null 2>&1
    done
    mv -f "settings.ini" "$HOME/.config/$conffolder-$oldde/settings.ini" >/dev/null 2>&1

    if [ -d "$HOME/.config/$conffolder-$newde" ]; then
        # Migrate current DE's configs from safekeeping back to their intended location
        cd "$HOME/.config/$conffolder-$newde"
        #  All folders
        for dir in ./*; do
            if [ -d "$dir" ]; then
                mv -f "$dir" "$HOME/.config/$conffolder/$dir" >/dev/null 2>&1
            fi
        done
        #  CSS and config files
        for i in ./*.css; do
            mv -f "$i" "$HOME/.config/$conffolder/$i" >/dev/null 2>&1
        done
        mv -f "settings.ini" "$HOME/.config/$conffolder/settings.ini" >/dev/null 2>&1
    fi
done
cd

#Backup prior DE's GNOME GSettings
echo "[org/gnome/desktop/interface]" > "$HOME/.config/feren-os/dconf-$oldde"
for i in $interfacegs; do
    value=$(dconf read /org/gnome/desktop/interface/$i)
    if [ ! -z "$value" ] && [ "$value" != "''" ]; then
        echo "$i=$value" >> "$HOME/.config/feren-os/dconf-$oldde"
    fi
done
echo "
[org/gnome/desktop/sound]" >> "$HOME/.config/feren-os/dconf-$oldde"
for i in $soundgs; do
    value=$(dconf read /org/gnome/desktop/sound/$i)
    if [ ! -z "$value" ] && [ "$value" != "''" ]; then
        echo "$i=$value" >> "$HOME/.config/feren-os/dconf-$oldde"
    fi
done
echo "
[org/gnome/desktop/peripherals/mouse]" >> "$HOME/.config/feren-os/dconf-$oldde"
for i in $mousegs; do
    value=$(dconf read /org/gnome/desktop/peripherals/mouse/$i)
    if [ ! -z "$value" ] && [ "$value" != "''" ]; then
        echo "$i=$value" >> "$HOME/.config/feren-os/dconf-$oldde"
    fi
done
echo "
[org/gnome/desktop/wm/preferences]" >> "$HOME/.config/feren-os/dconf-$oldde"
for i in $wmgs; do
    value=$(dconf read /org/gnome/desktop/wm/preferences/$i)
    if [ ! -z "$value" ] && [ "$value" != "''" ]; then
        echo "$i=$value" >> "$HOME/.config/feren-os/dconf-$oldde"
    fi
done

#Load defaults for appropriate gsettings before loading actual values
for i in $interfacegs; do
    dconf reset /org/gnome/desktop/interface/$i
done
for i in $soundgs; do
    dconf reset /org/gnome/desktop/sound/$i
done
for i in $mousegs; do
    dconf reset /org/gnome/desktop/peripherals/mouse/$i
done
for i in $wmgs; do
    dconf reset /org/gnome/desktop/wm/preferences/$i
done

#Load current DE's gsettings
if [ -f "$HOME/.config/feren-os/dconf-$newde" ]; then
    dconf load / < "$HOME/.config/feren-os/dconf-$newde"
fi


fi
fi
fi
