{
  nix-log,
  nixlib,
  ...
}:
with nixlib.lib;
with builtins;
with nix-log.lib;
  {
    baseModules ? {},
    darwinModules ? {},
    homeModules ? {},
    nixosModules ? {},
    systemModules ? {},
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

    baseModules' = modulate baseModules;

    systemModules' = merge baseModules' (modulate systemModules);
  in
    trace' "nix-modulate.lib.modulate" {
      inherit
        baseModules'
        darwinModules
        homeModules
        nixosModules
        systemModules'
        ;
    }
    {
      darwinModules = merge systemModules' (modulate darwinModules);
      homeModules = merge baseModules' (modulate homeModules);
      nixosModules = merge systemModules' (modulate nixosModules);
    }
