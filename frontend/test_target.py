import json
transcript_path = '/Users/irziarinta/.gemini/antigravity-ide/brain/7092ae61-982b-4be3-912e-dc3f65915025/.system_generated/logs/transcript.jsonl'
with open(transcript_path, 'r') as f:
    for line in f:
        step = json.loads(line)
        if 'tool_calls' in step:
            for call in step['tool_calls']:
                args = call['args']
                if not isinstance(args, dict): continue
                target_file = args.get('TargetFile', '')
                if 'admin_shell_page.dart' in target_file:
                    name = call['name']
                    if name == 'multi_replace_file_content':
                        desc = args.get('Description', '')
                        if "Update Movie saving UI feedback" in desc:
                            chunks = args.get('ReplacementChunks', [])
                            if isinstance(chunks, str): chunks = json.loads(chunks)
                            for i, c in enumerate(chunks):
                                print(f"Chunk {i} Target Length: {len(c['TargetContent'])}")
                                print(repr(c['TargetContent'][:50]))
