import json

transcript_path = '/Users/irziarinta/.gemini/antigravity-ide/brain/7092ae61-982b-4be3-912e-dc3f65915025/.system_generated/logs/transcript.jsonl'
file_path = '/Users/irziarinta/Downloads/cinema-ticket/frontend/lib/src/pages/admin_shell_page.dart'

# reset to last committed state
import subprocess
subprocess.run(['git', 'checkout', file_path])

with open(file_path, 'r') as f:
    content = f.read()

def apply_chunks(chunks):
    global content
    for chunk in chunks:
        target = chunk['TargetContent']
        replacement = chunk['ReplacementContent']
        if target in content:
            content = content.replace(target, replacement)
        else:
            print("Failed to find target of length", len(target))

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
                    # Skip the very last bad replacement (step ~2250)
                    desc = args.get('Description', '')
                    if "Fix layout overflow and add loading state" in desc or "Run auto-schedule in background" in desc:
                        print("Skipping bad chunk:", desc)
                        continue
                    if name == 'multi_replace_file_content':
                        chunks = args.get('ReplacementChunks', [])
                        if isinstance(chunks, str):
                            try: chunks = json.loads(chunks)
                            except: pass
                        if isinstance(chunks, list):
                            apply_chunks(chunks)
                    elif name == 'replace_file_content':
                        apply_chunks([args])

with open(file_path, 'w') as f:
    f.write(content)
print("Restored file successfully, length is", len(content.splitlines()))
