# Functions ported from github.com/jchiatt/dotfiles (init/shellrc.d)

# upto <dir>: cd to the named parent directory (tab-completes parents)
upto() {
  if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: upto <parent>  — cd to the named parent directory"; return
  fi
  cd "${PWD/\/$1\/*//$1}"
}
_upto() { local parents=(${(s:/:)PWD}); compadd -V 'Parent Dirs' -- "${(Oa)parents[@]}"; }
compdef _upto upto

# up [n]: go up n directories
up() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then echo "Usage: up [count]"; return; fi
  local count=${1:-1} path_str=""
  repeat $count path_str+="../"
  cd "$path_str"
}

# cdp [marker]: cd to the nearest parent containing marker (default .git)
cdp() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then echo "Usage: cdp [marker]  (default .git)"; return; fi
  local marker=${1:-.git} dir=$PWD
  while [[ -n "$dir" && ! -e "$dir/$marker" ]]; do dir=${dir%/*}; done
  [[ -n "$dir" ]] && cd "$dir"
}

# pj: print the project root (nearest parent with .git)
pj() {
  local dir=$PWD
  while [[ -n "$dir" && ! -e "$dir/.git" ]]; do dir=${dir%/*}; done
  echo "${dir:-.}"
}

# buf [from] [to]: timestamped .tgz backup of a file/dir (uses sudo if a ticket is active)
buf() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: buf [<from>] [<to>]  — timestamped .tgz backup of <from> into <to> (default .)"; return
  fi
  local src=$(realpath "${1:-.}") out=${2:-.}
  local name=${src:t} parent=${src:h}
  local file="${name}_$(date +%Y%m%d_%H%M%S).tgz"
  if sudo -nv 2>/dev/null; then
    sudo tar -czf "$out/$file" -C "$parent" --exclude "**/$file" --ignore-failed-read "$name" \
      && sudo chown "$(id -nu):$(id -ng)" "$out/$file"
  else
    tar -czf "$out/$file" -C "$parent" --exclude "**/$file" --ignore-failed-read "$name"
  fi
  echo "$out/$file"
}

# tmpit <paths>: move things to /tmp/.trash (gone on reboot)
tmpit() { mkdir -p /tmp/.trash && mv "$@" /tmp/.trash; }

# myip: public IP address
myip() { curl -fsS https://ifconfig.me; echo; }

# mount with no args: aligned columns
mount() { if (( $# == 0 )); then command mount | column -t; else command mount "$@"; fi; }

###
# Docker helpers (dk = docker + extras, dkc = docker compose + extras)

dk() {
  case "$1" in
    sh)  shift; dksh "$@" ;;
    ex)  shift; dkex "$@" ;;
    fsi) shift; dkfsi "$@" ;;
    fse) shift; dkfse "$@" ;;
    *)   docker "$@" ;;
  esac
}

# Shell into a container (or compose service)
dksh() {
  if docker inspect "$1" &>/dev/null; then docker exec -it "$1" bash
  elif docker compose ps "$1" &>/dev/null; then docker compose exec "$1" bash
  else echo "No such container '$1' found"; fi
}

# Run a command in a container (or compose service)
dkex() {
  if docker inspect "$1" &>/dev/null; then docker exec -it "$@"
  elif docker compose ps "$1" &>/dev/null; then docker compose exec "$@"
  else echo "No such container '$1' found"; fi
}

# List / export a container's filesystem (defaults to the latest container)
dkfsi() { docker export "${1:-$(docker ps -lq)}" | tar tf -; }
dkfse() {
  local id=${1:-$(docker ps -lq)}
  mkdir -p "$id" && docker export "$id" | tar xf - --owner="$(id -u)" --directory="$id"
}

dkc() {
  case "$1" in
    sh)  shift; dcsh "$@" ;;
    ex)  shift; dcex "$@" ;;
    fsi) shift; dcfsi "$@" ;;
    fse) shift; dcfse "$@" ;;
    *)   docker compose "$@" ;;
  esac
}
dcsh() { docker compose exec "$@" bash; }
dcex() { docker compose exec "$@"; }
dcfsi() {
  local id
  for id in $(docker compose ps -q "$@"); do docker export "$id" | tar tf -; done
}
# Export each service's filesystem into ./<service> (all services if none given)
dcfse() {
  local svc id
  local -a services=("$@")
  (( $#services )) || services=(${(f)"$(docker compose config --services)"})
  for svc in $services; do
    id=$(docker compose ps -q "$svc") || continue
    [[ -n $id ]] || continue
    mkdir -p "$svc" && docker export "$id" | tar xf - --owner="$(id -u)" --directory="$svc"
  done
}

# docker-helper volume clone SRC DST
docker-helper() {
  if [[ "$1 $2" != "volume clone" || -z "$3" || -z "$4" ]]; then
    echo "Usage: docker-helper volume clone SRC_VOLUME DST_VOLUME"; return 1
  fi
  local src=$3 dst=$4
  docker volume inspect "$src" &>/dev/null || { echo "The source volume '$src' does not exist"; return 1; }
  docker volume inspect "$dst" &>/dev/null && { echo "The destination volume '$dst' already exists"; return 1; }
  docker volume create --name "$dst" >/dev/null
  docker run --rm -v "$src":/from -v "$dst":/to alpine ash -c "cd /from && cp -av . /to"
}

###
# hda <ai> [<second_ai>]: agent-first Herdr layout (no editor).
#   main AI on the left (60%), optional second AI on the right, shell strip along the bottom.
#   e.g. `hda cx cy` → Claude + Codex. Need an editor? Alt+Enter to split, then `n`.
hda() {
  if [[ -z $1 ]]; then echo "Usage: hda <ai> [<second_ai>]   e.g. hda cx cy"; return 1; fi
  if [[ -z $HERDR_PANE_ID ]]; then echo "Run hda inside herdr (Super+Ctrl+Enter)."; return 1; fi
  local dir=$PWD main=$HERDR_PANE_ID second
  _hda_split() { herdr pane split "$1" --direction "$2" --ratio "$3" --cwd "$dir" --no-focus | jq -r '.result.pane.pane_id'; }

  herdr tab rename "$HERDR_TAB_ID" "${dir:t}" >/dev/null
  _hda_split "$main" down 0.85 >/dev/null              # bottom 15%: shell
  if [[ -n $2 ]]; then
    second=$(_hda_split "$main" right 0.6)             # right 40%: second AI
    herdr pane run "$second" "$2" >/dev/null
  fi
  herdr pane run "$main" "$1" >/dev/null               # left: main AI
  unfunction _hda_split
}
