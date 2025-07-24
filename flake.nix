{
  description = "dangreco/flakes environment";
  inputs.env.url = "path:./env";
  outputs = { env, ... }: env.lib.mkEnv (system: pkgs: { });
}
