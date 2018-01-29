QUERY=$1
NODE_DETAILS=$(/usr/local/bin/aws ec2 describe-instances --filters "Name=tag:Name,Values=*$QUERY*")
FILTERED_NODE_DETAILS=$(echo $NODE_DETAILS | /usr/local/bin/jq '.Reservations')

SEARCH_OUT="{\"items\": ["

for NODE in $(echo ${FILTERED_NODE_DETAILS} |  /usr/local/bin/jq -r '.[] | @base64'); do
    INSTANCE=$(echo $NODE |  base64 --decode | /usr/local/bin/jq -c '.Instances[0]')
    NODE_NAME=$(echo $INSTANCE |  /usr/local/bin/jq -c '(.Tags | map(select(.Key == "Name").Value))[0]')
    NODE_INSTANCE_ID=$(echo $INSTANCE |  /usr/local/bin/jq -c '.InstanceId' | sed -e 's/^"//' -e 's/"$//')
    NODE_IP=$(echo $INSTANCE |  /usr/local/bin/jq -c '.PublicIpAddress' | sed -e 's/^"//' -e 's/"$//')
    NODE_STATE=$(echo $INSTANCE | /usr/local/bin/jq -c '.State.Name' | sed -e 's/^"//' -e 's/"$//')
    SUBTITLE="$NODE_INSTANCE_ID $NODE_IP $NODE_STATE"
    SEARCH_OUT="$SEARCH_OUT{\"title\": $NODE_NAME, \"subtitle\": \"$SUBTITLE\", \"arg\":\"$NODE_IP\"},"
done

SEARCH_OUT="$SEARCH_OUT]}"

echo $SEARCH_OUT
