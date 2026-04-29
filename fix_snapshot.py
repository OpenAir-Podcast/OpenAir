import os
import glob

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    new_content = content.replace('snapshot.value', 'snapshot.data')
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

for root, _, files in os.walk('lib/views'):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))
