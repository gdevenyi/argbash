#!/usr/bin/env bash

# SC2154: the wrapped library has no optional args, so _args_*_opt is referenced but not assigned.
# shellcheck disable=SC2154

m4_define(_DEFAULT_WRAP_FLAGS, [])

# ARG_POSITIONAL_SINGLE([cmd], [the command])
# ARGBASH_WRAP([test-wrapleftovers-lib])
# ARG_DEFAULTS_POS()
# ARGBASH_GO

# opening escape square bracket: [

echo "CMD=$_arg_cmd,LEFTOVERS=${_arg_leftovers[*]},CMDLINE=${_args_test_wrapleftovers_lib[*]},"

# closing escape square bracket: ]
