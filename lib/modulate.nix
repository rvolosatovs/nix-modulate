{
  nix-log,
  nixlib,
  ...
}:
with nixlib.lib;
with builtins;
with nix-log.lib;
  {
    base ? {},
    darwin ? {},
    home ? {},
    nixos ? {},
    system ? {},
  }: let
    modulate = mapAttrs (name: spec:
      if isFunction spec
      then spec
      else {...}: spec);

    merge = lhs: rhs:
      trace' "nix-modulate.lib.modulate.merge" {
        inherit
          lhs
          rhs
          ;
      }
      rhs
      // mapAttrs (
        name: mod: args: let
          lhs = mod args;

          merged =
            if rhs ? ${name}
            then recursiveUpdate lhs (rhs.${name} args)
            else lhs;
        in
          trace' "nix-modulate.lib.modulate.merge.mapAttrs" {
            inherit
              args
              lhs
              merged
              mod
              name
              rhs
              ;
          }
          merged
      )
      lhs;

    baseModules = modulate base;

    systemModules = merge baseModules (modulate system);
  in
    trace' "nix-modulate.lib.modulate" {
      inherit
        base
        baseModules
        darwin
        home
        nixos
        system
        systemModules
        ;
    }
    {
      darwinModules = merge systemModules (modulate darwin);
      homeModules = merge baseModules (modulate home);
      nixosModules = merge systemModules (modulate nixos);
    }
