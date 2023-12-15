#!/usr/bin/env python3
import sys
import toml
import os
import re

validator_directory = sys.argv[1]
balances_toml = sys.argv[2]

balances_config = {}

# iterate over each validator config in the base directory
for subdir in os.listdir(validator_directory):
  alias = subdir
  subdir_path = os.path.join(validator_directory, subdir)

  if os.path.isdir(subdir_path):
    toml_files = [f for f in os.listdir(subdir_path) if f.endswith(".toml")]
    if len(toml_files) == 1:
      toml_file_path = os.path.join(subdir_path, toml_files[0])
      transactions_toml = toml.load(toml_file_path)
      if 'namada' in alias:
        balances_config[alias] = {
          'pk': transactions_toml['established_account'][0]['public_keys'][0],
          'address': transactions_toml['validator_account'][0]['address']
        }
      else:
        balances_config[alias] = {
          'pk': transactions_toml['established_account'][0]['public_keys'][0],
        }

output_toml = toml.load(balances_toml)
ACCOUNT_AMOUNT = "1000000000"
USER_AMOUNT = "10000"
FAUCET_AMOUNT = "8123372036854000000"

for entry in balances_config:
  for token in output_toml['token']:
    if entry == 'faucet-1':
      output_toml['token'][token][balances_config[entry]['pk']] = FAUCET_AMOUNT
    elif entry == 'steward-1':
      output_toml['token'][token][balances_config[entry]['pk']] = ACCOUNT_AMOUNT
    elif 'alum' in entry:
      output_toml['token'][token][balances_config[entry]['pk']] = USER_AMOUNT
    else:
      if 'NAM' in token:
        output_toml['token'][token][balances_config[entry]['pk']] = ACCOUNT_AMOUNT
        output_toml['token'][token][balances_config[entry]['address']] = ACCOUNT_AMOUNT
      else:
        output_toml['token'][token][balances_config[entry]['pk']] = ACCOUNT_AMOUNT


print(toml.dumps(output_toml))
