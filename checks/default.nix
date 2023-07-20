{
  self,
  nixlib,
  nix-flake-tests,
  nixpkgs,
  ...
}: pkgs:
with nixlib.lib;
with builtins; let
  res = self.lib.modulate {
    baseModules.test.options.default.base = mkOption {
      type = types.str;
      default = "base";
    };
    baseModules.test.options.default.baseConst = mkOption {
      type = types.str;
    };
    baseModules.test.options.default.baseFromConfig = mkOption {
      type = types.str;
    };

    systemModules.test = {config, ...}: {
      options.default.system = mkOption {
        type = types.str;
        default = "system";
      };
      options.default.systemConst = mkOption {
        type = types.str;
      };
      options.default.systemFromConfig = mkOption {
        type = types.str;
        default = config.fromConfig;
      };
    };

    darwinModules.test = {config, ...}: {
      options.default.baseConst.default = "darwin";
      options.default.baseFromConfig.default = config.fromConfig;

      options.default.systemConst.default = "darwin";
    };

    homeModules.test = {config, ...}: {
      options.default.baseConst.default = "home";
      options.default.baseFromConfig.default = config.fromConfig;
    };

    nixosModules.test = {config, ...}: {
      options.default.baseConst.default = "nixos";
      options.default.baseFromConfig.default = config.fromConfig;

      options.default.systemConst.default = "nixos";
    };
  };

  darwin = res.darwinModules.test {
    config.fromConfig = "darwin";
  };
  home = res.homeModules.test {
    config.fromConfig = "home";
  };
  nixos = res.nixosModules.test {
    config.fromConfig = "nixos";
  };

  nixosSystem = nixpkgs.lib.nixosSystem {
    system = pkgs.stdenv.buildPlatform.system;
    modules = [
      ({
        config,
        pkgs,
        ...
      }: {
        imports = [
          res.nixosModules.test
        ];
        options.nixosSystem.test = mkOption {
          type = types.str;
          default = config.default.system;
        };
        config.default.base = "nixosSystemBase";
        config.default.system = "nixosSystemSystem";
      })
    ];
  };
in {
  lib = nix-flake-tests.lib.check {
    inherit pkgs;

    tests.testModulateDefaultBaseDarwin.expected = "base";
    tests.testModulateDefaultBaseDarwin.expr = darwin.options.default.base.default;

    tests.testModulateDefaultBaseHome.expected = "base";
    tests.testModulateDefaultBaseHome.expr = home.options.default.base.default;

    tests.testModulateDefaultBaseNixos.expected = "base";
    tests.testModulateDefaultBaseNixos.expr = nixos.options.default.base.default;

    tests.testModulateDefaultBaseConstDarwin.expected = "darwin";
    tests.testModulateDefaultBaseConstDarwin.expr = darwin.options.default.baseConst.default;

    tests.testModulateDefaultBaseConstHome.expected = "home";
    tests.testModulateDefaultBaseConstHome.expr = home.options.default.baseConst.default;

    tests.testModulateDefaultBaseConstNixos.expected = "nixos";
    tests.testModulateDefaultBaseConstNixos.expr = nixos.options.default.baseConst.default;

    tests.testModulateDefaultBaseFromConfigDarwin.expected = "darwin";
    tests.testModulateDefaultBaseFromConfigDarwin.expr = darwin.options.default.baseFromConfig.default;

    tests.testModulateDefaultBaseFromConfigHome.expected = "home";
    tests.testModulateDefaultBaseFromConfigHome.expr = home.options.default.baseFromConfig.default;

    tests.testModulateDefaultBaseFromConfigNixos.expected = "nixos";
    tests.testModulateDefaultBaseFromConfigNixos.expr = nixos.options.default.baseFromConfig.default;

    tests.testModulateDefaultSystemConstDarwin.expected = "darwin";
    tests.testModulateDefaultSystemConstDarwin.expr = darwin.options.default.systemConst.default;

    tests.testModulateDefaultSystemConstHome.expected = false;
    tests.testModulateDefaultSystemConstHome.expr = home.options.default ? systemConst;

    tests.testModulateDefaultSystemConstNixos.expected = "nixos";
    tests.testModulateDefaultSystemConstNixos.expr = nixos.options.default.systemConst.default;

    tests.testModulateDefaultSystemFromConfigDarwin.expected = "darwin";
    tests.testModulateDefaultSystemFromConfigDarwin.expr = darwin.options.default.systemFromConfig.default;

    tests.testModulateDefaultSystemFromConfigHome.expected = false;
    tests.testModulateDefaultSystemFromConfigHome.expr = home.options.default ? systemFromConfig;

    tests.testModulateDefaultSystemFromConfigNixos.expected = "nixos";
    tests.testModulateDefaultSystemFromConfigNixos.expr = nixos.options.default.systemFromConfig.default;

    tests.testModulateDefaultNixosSystemOptionSystemConst.expected = "nixos";
    tests.testModulateDefaultNixosSystemOptionSystemConst.expr = nixosSystem.config.default.systemConst;

    tests.testModulateDefaultNixosSystemOptionBase.expected = "nixosSystemBase";
    tests.testModulateDefaultNixosSystemOptionBase.expr = nixosSystem.config.default.base;

    tests.testModulateDefaultNixosSystemOptionTest.expected = "nixosSystemSystem";
    tests.testModulateDefaultNixosSystemOptionTest.expr = nixosSystem.config.nixosSystem.test;
  };
}
