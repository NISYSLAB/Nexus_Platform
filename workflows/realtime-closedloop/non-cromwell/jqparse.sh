

function get() {
  local key=$1
  local text=$2
  ## Use the -r (or --raw-output) option to emit raw strings as output:
  echo "${text}" | jq -r ".${key}"

}
jsontext='{"id":"ae0dde76-e0d8-4cc1-ad5c-27c995d346cc","status":"Submitted"}'
get "id" "${jsontext}"
