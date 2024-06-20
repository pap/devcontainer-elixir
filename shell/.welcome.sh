echo "Elixir Devcontainer version: $ELIXIR_IMAGE_VERSION\n"
echo `mix hex.info` | awk '{ print "Elixir:\t" $4 "\nOTP:\t" $6 "\n"}'
echo "Terminal Docker tools aliases:"
echo " * alpine: launch an interactive alpine 3.20 container"
echo " * dive: inspect the layers of a Docker image"
echo " * ld: run lazydocker in a container"
eval "$(starship init zsh)"
