"""
The following script is adapted from: https://github.com/jblindsay/whitebox-tools/blob/master/whitebox_plugin_generator.py
to create Julia functions for this repo.

See the license information for the original WhiteboxTools repo below:

"The MIT License (MIT)

Copyright (c) 2017-2021 John Lindsay

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE."
"""

"""
This script is just used to automatically generate the convenience methods for each
of the plugin tools in the whitebox_tools.py script. It should be run each time new
tools are added to WhiteboxTools.exe and before a public release.
"""
from __future__ import print_function
import os
from os import path
import re
import json
from whitebox import WhiteboxTools

_underscorer1 = re.compile(r'(.)([A-Z][a-z]+)')
_underscorer2 = re.compile('([a-z0-9])([A-Z])')


def camel_to_snake(s):
    subbed = _underscorer1.sub(r'\1_\2', s)
    return _underscorer2.sub(r'\1_\2', subbed).lower()


wbt = WhiteboxTools()

toolboxes = wbt.toolbox('')
tb_set = set()
for tb in toolboxes.split('\n'):
    if tb.strip():
        tb_set.add(tb.strip().split(':')[1].strip())

tb_dict = {}
for tb in sorted(tb_set):
    tb_dict[tb] = []

tools = wbt.list_tools()

t = 1
for tool, description in tools.items():
    print(t, tool)
    t += 1
    tool_snaked = camel_to_snake(tool)
    if tool_snaked == "and":
        tool_snaked = "And"
    if tool_snaked == "or":
        tool_snaked = "Or"
    if tool_snaked == "not":
        tool_snaked = "Not"
    fn_def = "function {}(wbt_info::WhiteboxTools = wbt_info; ".format(tool_snaked)

    # description = t.strip().split(":")[1].rstrip('.')
    description = description.rstrip('.')

    arg_append_str = ""

    doc_str = ""
    toolbox = wbt.toolbox(tool).strip()
    parameters = wbt.tool_parameters(tool)
    j = json.loads(parameters)
    param_num = 0
    default_params = []
    for p in j['parameters']:
        st = r"{}"
        st_val = '' 

        json_str = json.dumps(
            p, sort_keys=True, indent=2, separators=(',', ': '))
        flag = p['flags'][len(p['flags']) - 1].replace('-', '')
        if flag == "class":
            flag = "cls"
        if flag == "input":
            flag = "i"
                
        doc_str += "{}- `{}`: {}. \n".format(st_val, flag, p['description'].rstrip('.'))
        
        pt = p['parameter_type']
        if 'Boolean' in pt:
            if p['default_value'] != None and p['default_value'] != 'false':
                default_params.append(
                    "{}=true, ".format(camel_to_snake(flag)))
            else:
                default_params.append(
                    "{}=false, ".format(camel_to_snake(flag)))

            arg_append_str += "    if {} === true\n        push!(args, \"{}\")\n    end\n".format(
                camel_to_snake(flag), p['flags'][len(p['flags']) - 1])
        else:
            if p['default_value'] != None:
                if p['default_value'].replace('.', '', 1).isdigit():
                    default_params.append("{}={}, ".format(
                        camel_to_snake(flag), p['default_value']))
                else:
                    default_params.append("{}=\"{}\", ".format(
                        camel_to_snake(flag), p['default_value']))

                arg_append_str += "    push!(args, \"{}=\" * string({}))\n".format(
                    p['flags'][len(p['flags']) - 1], camel_to_snake(flag))
            else:
                if not p['optional']:
                    fn_def += "{}, ".format(camel_to_snake(flag))
                    arg_append_str += "    push!(args, \"{}=\" * string({}))\n".format(
                        p['flags'][len(p['flags']) - 1], camel_to_snake(flag))
                else:
                    default_params.append(
                        "{}=nothing, ".format(camel_to_snake(flag)))
                    arg_append_str += "    if isnothing({}) === false\n        push!(args, \"{}=\" * string({}))\n    end\n".format(
                        flag, p['flags'][len(p['flags']) - 1], camel_to_snake(flag))

    for d in default_params:
        fn_def += d

    # fn_def = fn_def.rstrip(', ')
    fn_def += "callback::Union{Nothing,Function}=nothing)"
    doc_str += "- `callback::Union{Nothing,Function}`: Custom function for handling tool text outputs."

    fn = """

\"\"\"
    {}

{}.
# Arguments
{}
\"\"\"
{}
    args = []
    {}
    return run_tool("{}"; args, callback) # returns 1 if error
    
end
    """.format(fn_def.replace("function ", ""), description, doc_str.rstrip(), fn_def, arg_append_str.strip(), tool)
    tb_dict[toolbox].append(fn)

out_dir = os.path.join(os.path.expanduser("~"), "Downloads")
if not os.path.exists(out_dir):
    os.mkdir(out_dir)
out_file = os.path.join(out_dir, "deleteme.txt")
f = open(out_file, 'w')

for key, value in sorted(tb_dict.items()):
    f.write("\n{}\n".format('#' * (len(key) + 4)))
    f.write("# {} #\n".format(key))
    f.write("{}\n".format('#' * (len(key) + 4)))
    for v in sorted(value):
        # print(v)
        f.write("{}\n".format(v))

f.close()