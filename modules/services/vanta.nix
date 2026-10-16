{
  # The per-domain key comes from Vanta (Install Vanta Agent task), put it in /etc/vanta-key with mode 600.
  # The host sets services.vanta.ownerEmail.
  flake.modules.nixos.vanta =
    { inputs, ... }:
    {
      imports = [ inputs.nixos-vanta.nixosModules.default ];
      services.vanta = {
        enable = true;
        keyFile = "/etc/vanta-key";
        region = "eu";
      };
    };
}
