{ pkgs ? import <nixpkgs> {},
  system ? builtins.currentSystem }:

let
  zig-overlay = pkgs.fetchFromGitHub {
    owner = "arqv";
    repo = "zig-overlay";
    rev = "39d034932f72c5e66f290275bde65df1a57c9e86";
    sha256 = "sha256-KyJGu/PhH5kjCm7EAs6npI6qgKeWjetc2GPRfpP/5pM=";
  };
  gitignoreSrc = pkgs.fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore";
    rev = "c4662e662462e7bf3c2a968483478a665d00e717";
    sha256 = "1npnx0h6bd0d7ql93ka7azhj40zgjp815fw2r6smg8ch9p7mzdlx";
  };
  inherit (import gitignoreSrc { inherit (pkgs) lib; }) gitignoreSource;
  zig = (import zig-overlay { inherit pkgs system; }).master.latest;
in
pkgs.stdenvNoCC.mkDerivation {
  name = "zls";
  version = "master";
  src = gitignoreSource ./.;
  nativeBuildInputs = [ zig ];
  dontConfigure = true;
  dontInstall = true;
  buildPhase = ''
    mkdir -p $out
    zig build install -Drelease-safe=true -Ddata_version=master --prefix $out
  '';
  XDG_CACHE_HOME = ".cache";
}
