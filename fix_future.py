import os

files_to_fix = [
    'lib/views/widgets/podcast_index_search_card_grid.dart',
    'lib/views/widgets/podcast_card_list.dart',
    'lib/views/widgets/podcast_card_grid.dart',
    'lib/views/widgets/fyyd_search_card_grid.dart',
    'lib/views/widgets/discovery_podcast_card_grid.dart',
    'lib/views/widgets/discovery_podcast_card_list.dart',
    'lib/views/widgets/podcast_index_search_card_list.dart',
    'lib/views/widgets/fyyd_search_card_list.dart'
]

for filepath in files_to_fix:
    with open(filepath, 'r') as f:
        content = f.read()
    
    new_content = content.replace('FutureBuilder(', 'FutureBuilder<bool>(')
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")
