# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  myBtrfsOptions = [ "compress=zstd" "noatime" ];
in
{
  # filesystems
  fileSystems."/".options = myBtrfsOptions;
  fileSystems."/home".options = myBtrfsOptions;
  fileSystems."/nix".options = myBtrfsOptions;
  fileSystems."/var/log".options = myBtrfsOptions;
  fileSystems."/var/lib/machines".options = myBtrfsOptions;
  fileSystems."/var/lib/portables".options = myBtrfsOptions;
}

