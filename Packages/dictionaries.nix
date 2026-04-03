{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hunspell
    hunspellDicts.en_US
    aspell
    aspellDicts.en
    enchant
  ];
}