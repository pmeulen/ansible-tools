#teardown() {
#}

setup() {
  scripts_dir=${BATS_TEST_DIRNAME}/../scripts/
  environment_dir=/tmp/environment
}

# Verify that test environment prerequisites are there

@test "scripts directory exists" {
  echo scripts_dir=${scripts_dir}
  [ -d ${scripts_dir} ]
}

@test "create_new_environment.sh script exists" {
  [ -f ${scripts_dir}/create_new_environment.sh ]
}

@test "create_keydir.sh script exists" {
  [ -f ${scripts_dir}/create_keydir.sh ]
}

@test "encrypt.sh script exists" {
  [ -f ${scripts_dir}/encrypt.sh ]
}

@test "encrypt-file.sh script exists" {
  [ -f ${scripts_dir}/encrypt-file.sh ]
}

@test "gen_password.sh script exists" {
  [ -f ${scripts_dir}/gen_password.sh ]
}

@test "gen_selfsigned_cert.sh script exists" {
  [ -f ${scripts_dir}/gen_selfsigned_cert.sh ]
}

@test "gen_ssh_key.sh script exists" {
  [ -f ${scripts_dir}/gen_ssh_key.sh ]
}

@test "gen_ssl_server_cert.sh script exists" {
  [ -f ${scripts_dir}/gen_ssl_server_cert.sh ]
}

@test "openssl exists in path" {
  run which openssl
  [ "$status" -eq 0 ]
}

@test "keyczart exists in path" {
  run which keyczart
  [ "$status" -eq 0 ]
}

# run the create_new_environment.sh script
@test "create_new_environment" {
  rm -rf ${environment_dir}
  run ${scripts_dir}/create_new_environment.sh ${environment_dir}
  [ "$status" -eq 0 ]
}

# Verify that generated secrets exist
@test "ansible-keystore exists" {
  [ -d "${environment_dir}/ansible-keystore" ]
}

@test "some_password exists" {
  [ -f "${environment_dir}/password/some_password" ]
}

@test "some_secret exists" {
  [ -f "${environment_dir}/secret/some_secret" ]
}

@test "some_ssh_key.key exists" {
  [ -f "${environment_dir}/ssh/some_ssh_key.key" ]
}

@test "some_ssh_key.pub exists" {
  [ -f "${environment_dir}/ssh/some_ssh_key.pub" ]
}


@test "some_ssl_cert.crt exists" {
  [ -f "${environment_dir}/ssl_cert/some_ssl_cert.crt" ]
}

@test "some_ssl_cert.key exists" {
  [ -f "${environment_dir}/ssl_cert/some_ssl_cert.key" ]
}


@test "some_saml_cert.crt exists" {
  [ -f "${environment_dir}/saml_cert/some_saml_cert.crt" ]
}

@test "some_saml_cert.key exists" {
  [ -f "${environment_dir}/saml_cert/some_saml_cert.key" ]
}

