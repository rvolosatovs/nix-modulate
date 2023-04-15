{
  self,
  nixlib,
  nix-flake-tests,
  ...
}: pkgs:
with nixlib.lib;
with builtins; let
  res = self.lib.modulate {
    base.test.options.default.base = mkOption {
      type = types.str;
      default = "base";
    };
    base.test.options.default.baseConst = mkOption {
      type = types.str;
    };
    base.test.options.default.baseFromConfig = mkOption {
      type = types.str;
    };

    system.test = {config, ...}: {
      options.default.system = mkOption {
        type = types.str;
        default = "system";
      };
      options.default.systemConst = mkOption {
        type = types.str;
      };
      options.default.systemFromConfig = mkOption {
        type = types.str;
        default = config.default;
      };
    };

    darwin.test = {config, ...}: {
      options.default.baseConst.default = "darwin";
      options.default.baseFromConfig.default = config.default;

      options.default.systemConst.default = "darwin";
    };

    home.test = {config, ...}: {
      options.default.baseConst.default = "home";
      options.default.baseFromConfig.default = config.default;
    };

    nixos.test = {config, ...}: {
      options.default.baseConst.default = "nixos";
      options.default.baseFromConfig.default = config.default;

      options.default.systemConst.default = "nixos";
    };
  };

  darwin = res.darwinModules.test {
    config.default = "darwin";
  };
  home = res.homeModules.test {
    config.default = "home";
  };
  nixos = res.nixosModules.test {
    config.default = "nixos";
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
  };
}
