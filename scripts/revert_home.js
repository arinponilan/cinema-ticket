const fs = require('fs');

const logs = fs.readFileSync('/Users/irziarinta/.gemini/antigravity-ide/brain/7092ae61-982b-4be3-912e-dc3f65915025/.system_generated/logs/transcript.jsonl', 'utf8').split('\n');

let step160 = null;
for (const line of logs) {
  if (!line.trim()) continue;
  const obj = JSON.parse(line);
  if (obj.step_index === 160) {
    step160 = obj.tool_calls[0].args;
    break;
  }
}

const targetFilePath = step160.TargetFile.replace(/^"|"$/g, '');
let content = fs.readFileSync(targetFilePath, 'utf8');

function cleanLogString(str) {
  if (typeof str !== 'string') return str;
  let s = str.replace(/^"+|"+$/g, '');
  s = s.replace(/\\n/g, '\n')
       .replace(/\\t/g, '\t')
       .replace(/\\r/g, '\r')
       .replace(/\\"/g, '"')
       .replace(/\\\\/g, '\\');
  return s.replace(/^"+|"+$/g, '');
}

const targetContentRaw = cleanLogString(step160.TargetContent);
const replacementContentRaw = cleanLogString(step160.ReplacementContent);

const normalizedContent = content.replace(/\r\n/g, '\n');
const normalizedTarget = targetContentRaw.replace(/\r\n/g, '\n');

let matchLen = 0;
while (matchLen < normalizedTarget.length) {
  const sub = normalizedTarget.substring(0, matchLen + 1);
  if (normalizedContent.includes(sub)) {
    matchLen++;
  } else {
    break;
  }
}
console.log("Matched length:", matchLen, "out of", normalizedTarget.length);
console.log("Remaining target context:", JSON.stringify(normalizedTarget.substring(matchLen, matchLen + 100)));
