#teardown() {
#}

setup() {
  scripts_dir=${BATS_TEST_DIRNAME}/../scripts/
  key_dir=/tmp/key_dir
  enc_dir=/tmp/enc_dir
}

# Verify that test environment prerequisites are there

@test "scripts directory exists" {
  echo scripts_dir=${scripts_dir}
  [ -d ${scripts_dir} ]
}

@test "encrypt.sh exists" {
  [ -f ${scripts_dir}/encrypt.sh ]
}

@test "encrypt-file.sh exists" {
  [ -f ${scripts_dir}/encrypt.sh ]
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

@test "encrypt.sh --help" {
  run ${scripts_dir}/encrypt.sh --help
  [ "$status" -eq 0 ]
}

@test "encrypt-file.sh --help" {
  run ${scripts_dir}/encrypt-file.sh --help
  [ "$status" -eq 0 ]
}

@test "encrypt using encrypt-file.sh" {
   rm -rf ${enc_dir}
   mkdir ${enc_dir}
   echo "plaintext-string\nline2" > ${enc_dir}/plain
   run ${scripts_dir}/encrypt-file.sh -f ${enc_dir}/plain ${key_dir}
   [ "$status" -eq 0 ]
   echo $output > ${enc_dir}/encrypted
}

@test "decrypt using encrypt-file.sh" {
    run ${scripts_dir}/encrypt-file.sh -d -f ${enc_dir}/encrypted ${key_dir}
    [ "$status" -eq 0 ]
    [ "plaintext-string\nline2" == "$output" ]
}

@test "decrypt using ansible vault filter" {
    rm -f /tmp/enc_dir/decrypted
    run ansible-playbook ../test.yml
    [ "$status" -eq 0 ]
    [ "plaintext-string\nline2" == "`cat ${enc_dir}/decrypted`" ]
}

@test "encrypt using encrypt.sh" {
    run expect -f encrypt.expect
    [ "$status" -eq 0 ]
}

@test "decrypt using encrypt.sh" {
    encrypted=`cat /tmp/enc_dir/enc`
    run expect -f decrypt.expect $encrypted
    [ "$status" -eq 0 ]
    decrypted=`cat /tmp/enc_dir/enc`
    [ "$encrypted" == "$decrypted" ]
}
