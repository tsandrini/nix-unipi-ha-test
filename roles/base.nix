{ inputs, user, ... }: {
  # TODO will decouple when I'll have most of the stuff done
  imports = with inputs.self; [
    # --------------------
    # | EXTERNAL MODULES |
    # --------------------
    inputs.home-manager.nixosModules.home-manager
    # inputs.agenix.nixosModules.default
    {
      system.stateVersion = "23.05";
    }

    # -----------
    # | MODULES |
    # -----------
    # nixosModules.hello

    # ------------
    # | PROFILES |
    # ------------
    nixosProfiles.tty
    nixosProfiles.system-maintenance
    nixosProfiles.system-packages
    nixosProfiles.localization
    nixosProfiles.networking-nm
    nixosProfiles.home-manager
  ];
}
