#!/bin/sh
# shellcheck disable=SC2094
# shellcheck disable=SC2129
IFS=$(printf '\n\t')
set -e
OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(git rev-parse --show-toplevel)
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)

# @param
# $1 string filepath
cp_role_page(){
  RELATIVE=$(realpath --relative-to="$OWN_DIR" "$(dirname "$1")")
  if [ ! -d "$OWN_DIR/docs/$RELATIVE" ]; then
    mkdir -p "$OWN_DIR/docs/$RELATIVE"
  fi
  cp "$1" "$OWN_DIR/docs/$RELATIVE/index.md"
}

# @param
# $1 string folder
cp_single_page(){
  if [ ! -d "$OWN_DIR/docs/$1" ]; then
    mkdir "$OWN_DIR/docs/$1"
  fi
  cp "$OWN_DIR/$1/README.md" "$OWN_DIR/docs/$1/$1.md"
}

# @param
# $1 (string) filename
parse_role_variables(){
  TMP_MD=$(mktemp)
  WRITE=1
  # Ensure we have a trailing line.
  echo "" >> "$1"
  while read -r LINE; do
    case $LINE in
    '<!--ROLEVARS-->')
      echo "$LINE" >> "$TMP_MD"
      generate_role_variables "$1"
      WRITE=0
    ;;
    '<!--ENDROLEVARS-->')
      echo "$LINE" >> "$TMP_MD"
      WRITE=1
    ;;
    *)
    if [ $WRITE = 1 ]; then
      echo "$LINE" >> "$TMP_MD"
    fi
    ;;
    esac
  done < "$1"
  printf '%s\n' "$(cat "$TMP_MD")" > "$1"
  rm "$TMP_MD"
}

# @param
# $1 (string) filename
generate_role_variables(){
  VAR_FILE="$(dirname "$1")/defaults/main.yml"
  if [ -f "$VAR_FILE" ]; then
    echo "## Default variables"  >> "$TMP_MD"
    echo '```yaml' >> "$TMP_MD"
    cat "$VAR_FILE" >> "$TMP_MD"
    echo "" >> "$TMP_MD"
    echo '```' >> "$TMP_MD"
    echo "" >> "$TMP_MD"
  fi
}

generate_roles_toc(){
  TMP_SIDEBAR=$(mktemp)
  WRITE="true"
  while read -r LINE; do
    case $LINE in
    "  - [Roles](roles)")
      echo "$LINE" >> "$TMP_SIDEBAR"
      parse_roles_toc roles 2
      WRITE="false"
    ;;
    "  -"*)
      WRITE="true"
      echo "$LINE" >> "$TMP_SIDEBAR"
    ;;
    *)
    if [ "$WRITE" = "true" ]; then
      echo "$LINE" >> "$TMP_SIDEBAR"
    fi
    ;;
    esac
  done < "$OWN_DIR/docs/_Sidebar.md"
  mv "$TMP_SIDEBAR" "$OWN_DIR/docs/_Sidebar.md"
}

parse_roles_toc(){
  ROLES=$(find "$OWN_DIR/$1" -mindepth "$2" -maxdepth "$2" -name "README.md" | sort)
  for ROLE in $ROLES; do
    WRITE="true"
    INDENT=$(printf %$(($2 * 2))s)
    RELATIVE=$(realpath --relative-to="$OWN_DIR" "$(dirname "$ROLE")")
    while read -r LINE; do
      case $LINE in
      "# "*)
        if [ "$WRITE" = "true" ]; then
          TITLE=$(echo "$LINE" | cut -c 3-)
          echo "$INDENT"" - [$TITLE]($RELATIVE)" >> "$TMP_SIDEBAR"
          WRITE="false"
        fi
      ;;
      esac
    done < "$ROLE"
  parse_roles_toc "$RELATIVE" $(($2 + 1))
  done
}

rm -rf "$OWN_DIR/docs/roles"
ROLE_PAGES=$(find "$OWN_DIR/roles" -name "README.md")
for ROLE_PAGE in $ROLE_PAGES; do
  parse_role_variables "$ROLE_PAGE"
done
for ROLE_PAGE in $ROLE_PAGES; do
  cp_role_page "$ROLE_PAGE"
done
generate_roles_toc


cp_single_page install
cp_single_page contribute
cp_single_page scripts