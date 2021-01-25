export PATH=./:/base/bin:/base/sbin:/usr/local/bin:/usr/local/sbin:/bin:/sbin:./bin:./sbin:$PATH
OIFS=$IFS
IFS=':' read -ra APATH <<< "$PATH"
NPATH=""
for a in "${APATH[@]}"; do
    FOUND=$(echo $NPATH | egrep -e "^${a}:|:${a}:|${a}$")

    if [ "$FOUND" == "" ]; then
        NPATH+="${a}:"
    fi
done
IFS=$OIFS
NPATH=$(echo $NPATH | sed -e "/::/s//:/g" -e "/:$/s///g")
export PATH=$NPATH
