#teardown() {
#}

setup() {
  scripts_dir=${BATS_TEST_DIRNAME}/../scripts/
  key_dir=/tmp/key_dir
}

# Verify that test environment prerequisites are there

@test "scripts directory exists" {
  echo scripts_dir=${scripts_dir}
  [ -d ${scripts_dir} ]
}

@test "create_keydir.sh script exists" {
  [ -f ${scripts_dir}/create_keydir.sh ]
}

@test "keyczart exists in path" {
  run which keyczart
  [ "$status" -eq 0 ]
}

# run the create_keydir.sh script
@test "create_keydir" {
  rm -rf ${key_dir}
  run ${scripts_dir}/create_keydir.sh ${key_dir}
  [ "$status" -eq 0 ]
}

@test "keydir exists" {
  [ -d ${key_dir} ]
}