#!/usr/bin/env python3
import sys
import toml
import os
import re

validator_directory = sys.argv[1]
balances_toml = sys.argv[2]

balances_config = {}
bertha_pk = 'tpknam1qpyfnrl6qdqvguah9kknvp9t6ajcrec7fge56pcgaa655zkua3nds48x83t'

# iterate over each validator config in the base directory
for subdir in os.listdir(validator_directory):
  alias = subdir
  subdir_path = os.path.join(validator_directory, subdir)

  if os.path.isdir(subdir_path):
    toml_files = [f for f in os.listdir(subdir_path) if f.endswith(".toml")]
    if len(toml_files) == 1:
      toml_file_path = os.path.join(subdir_path, toml_files[0])
      transactions_toml = toml.load(toml_file_path)
      balances_config[alias] = {
        'account_key': {
          'pk': transactions_toml['validator_account'][0]['account_key']['pk'],
          'authorization': transactions_toml['validator_account'][0]['account_key']['authorization']
          },
        'source': {
          'pk': transactions_toml['transfer'][0]['source']
        }
      }

# add an entry for 'bertha' (pgf steward account)
balances_config['bertha'] = {'pk': bertha_pk}

output_toml = toml.load(balances_toml)

for entry in balances_config:
  if entry == 'bertha':
    output_toml['token']['NAM'][balances_config['bertha']['pk']] = "1000000"
  else:
    output_toml['token']['NAM'][balances_config[entry]['account_key']['pk']] = "1000000"
    output_toml['token']['NAM'][balances_config[entry]['source']['pk']] = "10000000"

    output_toml['token']['BTC'][balances_config[entry]['account_key']['pk']] = "1000000"
    output_toml['token']['BTC'][balances_config[entry]['source']['pk']] = "10000000"

    output_toml['token']['ETH'][balances_config[entry]['account_key']['pk']] = "1000000"
    output_toml['token']['ETH'][balances_config[entry]['source']['pk']] = "10000000"
    
    output_toml['token']['DOT'][balances_config[entry]['account_key']['pk']] = "1000000"
    output_toml['token']['DOT'][balances_config[entry]['source']['pk']] = "10000000"
    
    output_toml['token']['Schnitzel'][balances_config[entry]['account_key']['pk']] = "1000000"
    output_toml['token']['Schnitzel'][balances_config[entry]['source']['pk']] = "10000000"
    
    output_toml['token']['Apfel'][balances_config[entry]['account_key']['pk']] = "1000000"
    output_toml['token']['Apfel'][balances_config[entry]['source']['pk']] = "10000000"
    
    output_toml['token']['Kartoffel'][balances_config[entry]['account_key']['pk']] = "1000000"
    output_toml['token']['Kartoffel'][balances_config[entry]['source']['pk']] = "10000000"

print(toml.dumps(output_toml))
