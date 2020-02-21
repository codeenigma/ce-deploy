#!/bin/sh
# shellcheck disable=SC2094

OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(git rev-parse --show-toplevel)
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)

# Top level folders.
FIRST_LEVEL_DIRS="install scripts roles contribute"
# Initial state
SUBPAGES=""
TMP_MD="$OWN_DIR/.toc-tmp.md"
FIRST_PASS="true"
# @param
# $1 (string) filename
parse_page(){
  if [ -f "$TMP_MD" ]; then
    rm "$TMP_MD"
  fi
  WRITE=1
  # Ensure we have a trailing line.
  echo "" >> "$1"
  while read -r LINE; do
    case $LINE in
    '<!--TOC-->')
      echo "$LINE" >> "$TMP_MD"
      generate_toc "$1"
      WRITE=0
    ;;
    '<!--ENDTOC-->')
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
  FIRST_PASS="false"
  parse_subpages "$1"
}
parse_subpages(){
  get_subpages "$1"
  for SUBPAGE in $SUBPAGES; do
    parse_page "$SUBPAGE"
  done
}

# @param
# $1 (string) filename
generate_toc(){
  get_subpages "$1"
  for SUBPAGE in $SUBPAGES; do
      extract_toc "$SUBPAGE" "$(dirname "$1")"
  done
}
# @param
# $1 (string) filename
get_subpages(){
  DIRNAME=$(dirname "$1")
  SUBPAGES=$(find "$DIRNAME" -mindepth 2 -maxdepth 3 -name "README.md" | sort -r )
  if [ "$FIRST_PASS" = "true" ]; then
    SUBPAGES=""
    for FOLDER in $FIRST_LEVEL_DIRS; do
      SUBPAGES="$SUBPAGES $OWN_DIR/$FOLDER/README.md"
      SUBPAGES="$SUBPAGES $(find "$OWN_DIR/$FOLDER" -mindepth 2 -maxdepth 2 -name "README.md" | sort -r )"
    done
  fi
}
# @param
# $1 (string) filename
# $2 (string) relative dirname
extract_toc(){
  WRITE_TITLE="true"
  WRITE_INTRO="false"
  INNER_TOC="false"
  RELATIVE=$(realpath --relative-to="$2" "$1")
  INDENT=$(echo "$RELATIVE" | grep -o '/' | tr -d "\n" | tr '/' '#')
  while read -r LINE; do
    case $LINE in
    "# "*)
      if [ "$WRITE_TITLE" = "true" ]; then
        TITLE=$(echo "$LINE" | cut -c 3-)
        echo "#$INDENT"" [$TITLE]($RELATIVE)" >> "$TMP_MD"
        WRITE_TITLE="false"
        WRITE_INTRO="true"
      fi
    ;;
    "<!--ENDTOC"*)
      INNER_TOC="false"
    ;;
    "<!--"*)
      INNER_TOC="true"
      WRITE_INTRO="false"
    ;;
    "## "*)
      if [ "$INNER_TOC" = "false" ]; then
        if [ "$(echo "$INDENT" | wc -m)" = "2" ]; then
          TITLE=$(echo "$LINE" | cut -c 4-)
          ANCHOR=$(echo "$TITLE" | tr ' ' '-'|  tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9\-')
          echo "##$INDENT"" [$TITLE]($RELATIVE#$ANCHOR)" >> "$TMP_MD"
        fi
      fi
      WRITE_INTRO="false"
    ;;
    *)
    if [ "$WRITE_INTRO" = "true" ] && [ "$INNER_TOC" = "false" ]; then
      echo "$LINE" >> "$TMP_MD"
    fi
    ;;
    esac
  done < "$1"
}

# @param
# $1 (string) filename
parse_role_variables(){
  if [ -f "$TMP_MD" ]; then
    rm "$TMP_MD"
  fi
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

# @param
# $1 (string) filename
cp_file(){
  RELATIVE=$(realpath --relative-to="$OWN_DIR" "$(dirname "$1")")
  TARGET_DIR="$OWN_DIR/docs/$RELATIVE"
  if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
  fi
  cp "$1" "$TARGET_DIR/"
}

# TOC Generation.
parse_page "$OWN_DIR/README.md"
# Inject Ansible vars for roles.
ROLE_PAGES=$(find "$OWN_DIR/roles" -name "README.md")
for ROLE_PAGE in $ROLE_PAGES; do
  parse_role_variables "$ROLE_PAGE"
done
# Generates docs folder.
rm -rf "$OWN_DIR/docs/*"
cp "$OWN_DIR/README.md" "$OWN_DIR/docs/"
for FIRST_LEVEL in $FIRST_LEVEL_DIRS; do
  # Can't easily use exec here.
  MD_FILES=$(find "$OWN_DIR/$FIRST_LEVEL" -name "README.md")
  for MD_FILE in $MD_FILES; do
    cp_file "$MD_FILE"
  done
done
if [ -f "$TMP_MD" ]; then
  rm "$TMP_MD"
fi