#!/usr/bin/env python3

import sys
import json
import math

docs_cache_directory = sys.argv[1]
raw_docs_cache_path = f"{docs_cache_directory}/cache_info"
formatted_docs_cache_path = f"{raw_docs_cache_path}_formatted"

active_group = None
active_command = None
print_first_group = True
print_last_group  = True

# All the doc date is stored here.
# Keyed on group, then comand

saved_docs_info = {}

with open(raw_docs_cache_path,'r') as input_file:
    for input_line in input_file:
        input_line = input_line.strip()
        group_parts = input_line.split(':: ')
        current_group = group_parts[0]
        command_parts = group_parts[1].split(": ")
        current_command = command_parts[0]
        current_doc =  command_parts[1]

        # Save off the information
        saved_group_info = saved_docs_info.get(current_group,{})
        saved_group_info[current_command] = current_doc
        saved_docs_info[current_group] = saved_group_info

with open(formatted_docs_cache_path,'w') as output_file:
    print(f"\nCommands summary\n\n",file=output_file)
    groups = saved_docs_info.keys()
    sorted_groups = sorted(groups)
    for sorted_group in sorted_groups:
        print(f"{sorted_group} commands\n",file=output_file)
        group_info = saved_docs_info.get(sorted_group,{})
        individual_commands = group_info.keys()
        sorted_individual_commands = sorted(individual_commands)

        max_command_length = 0
        for individual_command in sorted_individual_commands:
            max_command_length = max(max_command_length, len(individual_command)) 

        for individual_command in sorted_individual_commands:
            current_doc = group_info.get(individual_command,'')
            formatted_individual_command = (individual_command + (' ' * max_command_length))[0:(max_command_length+1)]
            print(f"{formatted_individual_command} {current_doc}",file=output_file)

        print("\n", file=output_file)