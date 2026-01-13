#!/usr/bin/env bash

volume_up() {
    pamixer --increase 5
}
volume_down() {
    pamixer --decrease 5
}
volume_mute() {
    pamixer --toggle-mute
}
# Brightness controls
brightness_up() {
    brightnessctl -q set +5%
}
brightness_down() {
    brightnessctl -q set 5%-
}
# Mic mute control
mic_mute() {
    pamixer --default-source --toggle-mute
}
# Main command dispatcher
case "${1:-}" in
    volume-up)
        volume_up
        ;;
    volume-down)
        volume_down
        ;;
    volume-mute)
        volume_mute
        ;;
    brightness-up)
        brightness_up
        ;;
    brightness-down)
        brightness_down
        ;;
    mic-mute)
        mic_mute
        ;;
    *)
        echo "Usage: osd-control {volume-up|volume-down|volume-mute|brightness-up|brightness-down|mic-mute}"
        exit 1
        ;;
esac
