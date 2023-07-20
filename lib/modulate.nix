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
    modulate = mapAttrs (
      name: spec:
        trace' "nix-modulate.lib.modulate.modulate.mapAttrs" {
          inherit
            name
            spec
            ;
        } (
          if isFunction spec
          then spec
          else {...}: spec
        )
    );

    merge = lhs: rhs:
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

    baseModules' =
      trace "nix-modulate.lib.modulate.baseModules'"
      modulate
      baseModules;

    homeModules' =
      trace "nix-modulate.lib.modulate.homeModules'"
      merge
      baseModules' (modulate homeModules);

    systemModules' =
      trace "nix-modulate.lib.modulate.systemModules'"
      merge
      baseModules' (modulate systemModules);

    darwinModules' =
      trace "nix-modulate.lib.modulate.darwinModules'"
      merge
      systemModules' (modulate darwinModules);

    nixosModules' =
      trace "nix-modulate.lib.modulate.nixosModules'"
      merge
      systemModules' (modulate nixosModules);
  in
    trace' "nix-modulate.lib.modulate" {
      inherit
        baseModules'
        darwinModules'
        homeModules'
        nixosModules'
        systemModules'
        ;
    }
    {
      darwinModules = darwinModules';
      homeModules = homeModules';
      nixosModules = nixosModules';
    }
