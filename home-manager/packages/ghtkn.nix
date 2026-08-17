# ghtkn is not packaged in nixpkgs, so it is built here.
#
# It is the first tool a fresh machine needs: it mints the GitHub App user
# access token that everything else (nekomata, kareha, ranbiki) is fetched
# with. Building it from the same declarative pipeline as every other package
# removes the need to curl a binary before any token exists.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "ghtkn";
  # renovate: datasource=github-releases depName=suzuki-shunsuke/ghtkn
  #
  # NOTE: renovate bumps this version but cannot compute the two hashes below.
  # After a bump they go stale and the build fails. Run nix-update, or build
  # twice and copy the `got:` value out of each hash mismatch error.
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "suzuki-shunsuke";
    repo = "ghtkn";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H1dyBbwq3jVftk/90f6iDrwiTTwvnGYOWALATrLsBHc=";
  };

  vendorHash = "sha256-7mw8SPjs6HCQVx62yoKugSf1J/rqsG9uBfVCfsVWpnY=";

  subPackages = [ "cmd/ghtkn" ];

  # golang.design/x/clipboard is a direct dependency and would drag in X11 on
  # Linux and Cocoa on Darwin, but upstream ships every release binary with
  # CGO_ENABLED=0 (see .goreleaser.yml), so match that and keep this a pure Go
  # build with no native dependencies.
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "CLI to create short-lived GitHub App user access tokens for secure local development";
    homepage = "https://github.com/suzuki-shunsuke/ghtkn";
    license = lib.licenses.mit;
    mainProgram = "ghtkn";
  };
})
