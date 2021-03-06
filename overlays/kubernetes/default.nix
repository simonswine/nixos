self: super:
{
  kubernetes = super.kubernetes.overrideAttrs (
    old: rec {
      version = "1.18.16";

      src = super.fetchFromGitHub {
        owner = "kubernetes";
        repo = "kubernetes";
        rev = "v${version}";
        sha256 = "1ln5li45rkcgwzd0gbsjdwnih70w35xxw1w1w9nl062fx7r7bid2";
      };

    }
  );
}
