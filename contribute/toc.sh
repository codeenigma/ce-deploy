#!/bin/sh
# shellcheck disable=SC2094
# shellcheck disable=SC2000
# shellcheck disable=SC2129

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
# $1 (string) relative dirname
# $2 (string) list of all relative dirnames
parse_page(){
  SOURCE_FILE="$OWN_DIR/docs/$1/README.md"
  if [ "$FIRST_PASS" = "true" ]; then
    SOURCE_FILE="$OWN_DIR/docs/README.md"
  fi
  if [ -f "$TMP_MD" ]; then
    rm "$TMP_MD"
  fi
  touch "$TMP_MD"
  WRITE=1
  # Ensure we have a trailing line.
  echo "" >> "$SOURCE_FILE"
  while read -r LINE; do
    case $LINE in
    '<!--TOC-->')
      echo "$LINE" >> "$TMP_MD"
      generate_toc "$1" "$2"
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
  done < "$SOURCE_FILE"
  printf '%s\n' "$(cat "$TMP_MD")" > "$SOURCE_FILE"
  rm "$TMP_MD"
  FIRST_PASS="false"
}
parse_pages(){
  ORDERED_DIRS="docs"
  for FIRST_LEVEL_DIR in $FIRST_LEVEL_DIRS; do
    rm -rf "$OWN_DIR/docs/$FIRST_LEVEL_DIR"
    PAGES=$(find "$OWN_DIR/$FIRST_LEVEL_DIR" -name README.md)
    PAGES_DIRS=""
    for PAGE in $PAGES; do
      RELATIVE=$(realpath --relative-to="$OWN_DIR" "$(dirname "$PAGE")")
      RELATIVE=$(printf '%s' "$RELATIVE" | sed "s@/_@/@g")
      PAGES_DIRS="$PAGES_DIRS\n$RELATIVE"
      # Create folder structure and copy page.
      mkdir -p "$OWN_DIR/docs/$RELATIVE"
      cp "$PAGE" "$OWN_DIR/docs/$RELATIVE"
    done
    ORDERED_DIRS="$ORDERED_DIRS $(echo "$PAGES_DIRS" | sort)"
  done
  for ORDERED in $ORDERED_DIRS; do
    parse_page "$ORDERED" "$ORDERED_DIRS"
  done
}

# @param
# $1 (string) relative dirname
# $2 (string) list of all relative dirnames
generate_toc(){
  get_subpages "$1" "$2"
  for SUBPAGE in $SUBPAGES; do
    extract_toc "$SUBPAGE" "$1"
  done
}
# @param
# $1 (string) relative dirname
# $2 (string) list of all relative dirnames
get_subpages(){
  SUBPAGES=""
  for ORDERED in $2; do
    OWN_LEVEL=$(echo "$ORDERED" | grep -o '/' | wc -m)
    BASE_LEVEL=$(echo "$1" | grep -o '/' | wc -m)
    LEVEL=$((OWN_LEVEL-BASE_LEVEL))
    case $ORDERED in
      $1/*)
      if [ "$LEVEL" -lt 3 ]; then
        SUBPAGES="$SUBPAGES $ORDERED"
      fi
      ;;
      *)
      if [ "$FIRST_PASS" = "true" ] && [ "$LEVEL" -lt 3 ] && [ ! "$ORDERED" = "$1" ]; then
        SUBPAGES="$SUBPAGES $ORDERED"
      fi
      ;;
    esac
  done
}
# @param
# $1 (string) relative dirname
# $2 (string) parent relative dirname
extract_toc(){
  WRITE_TITLE="true"
  WRITE_INTRO="false"
  INNER_TOC="false"
  INDENT="#$(realpath --relative-to="$2" "$1" | grep -o '/' | tr -d "\n" | tr '/' '#')"
  if [ $FIRST_PASS = "false" ]; then
    INDENT="#$INDENT"
  fi
  while read -r LINE; do
    case $LINE in
    "# "*)
      if [ "$WRITE_TITLE" = "true" ]; then
        TITLE=$(echo "$LINE" | cut -c 3-)
        echo "$INDENT"" [$TITLE]($1/README.md)" >> "$TMP_MD"
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
          echo "$INDENT"" [$TITLE]($1/README.md#$ANCHOR)" >> "$TMP_MD"
        fi
      fi
      WRITE_INTRO="false"
    ;;
    *)
    # Any special chars means we're passed the intro.
    if echo "$LINE" | grep -q -E '^[^a-zA-Z0-9 -]'; then
      WRITE_INTRO="false" 
    fi
    if [ "$WRITE_INTRO" = "true" ] && [ "$INNER_TOC" = "false" ]; then
      echo "$LINE" >> "$TMP_MD"
    fi
    ;;
    esac
  done < "$OWN_DIR/docs/$1/README.md"
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

ROLE_PAGES=$(find "$OWN_DIR/roles" -name "README.md")
for ROLE_PAGE in $ROLE_PAGES; do
  parse_role_variables "$ROLE_PAGE"
done

# TOC Generation.
parse_pages