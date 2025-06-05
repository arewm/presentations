#!/bin/bash

# Create new presentation with paired HTML and Markdown files in a dedicated directory
# Usage: ./templates/create-presentation.sh presentation-name "Presentation Title"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <presentation-name> [presentation-title]"
    echo "Example: $0 my-awesome-talk \"My Awesome Talk\""
    echo "Note: Run this script from the presentations repository root"
    exit 1
fi

PRESENTATION_NAME="$1"
PRESENTATION_TITLE="${2:-$(echo $1 | sed 's/-/ /g' | sed 's/\b\w/\U&/g')}"

# Ensure we're running from repository root
if [ ! -f "STRUCTURE.md" ] || [ ! -d "templates" ]; then
    echo "Error: Please run this script from the presentations repository root"
    echo "Usage: ./templates/create-presentation.sh presentation-name"
    exit 1
fi

# Create directory for the presentation
echo "Creating presentation directory: ${PRESENTATION_NAME}/"
mkdir -p "$PRESENTATION_NAME"
mkdir -p "${PRESENTATION_NAME}/img"

# Create markdown file
cat > "${PRESENTATION_NAME}/${PRESENTATION_NAME}.md" << EOF
class: center, middle, title-slide

# ${PRESENTATION_TITLE}

## Subtitle

### Your Name
### Date

---

## Overview

- Topic 1
- Topic 2  
- Topic 3

---

## Slide 1

Content goes here...

.footnote[Add footnotes with .footnote[text]]

---

## Slide 2

More content with formatting:

- .highlight[Highlighted text]
- .red[Red text for emphasis]
- **Bold** and *italic* text

---

## Two Column Layout

.left-column[
### Left Side
- Point 1
- Point 2
]

.right-column[
### Right Side
- Point A
- Point B
]

---

## Code Example

\`\`\`python
def hello_world():
    print("Hello, World!")
    
hello_world()
\`\`\`

---

class: center, middle

# Questions?

### Thank you!

???
Speaker notes go here. Press 'P' for presenter mode.
EOF

# Create HTML file using the generic template structure
cat > "${PRESENTATION_NAME}/${PRESENTATION_NAME}.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>PRESENTATION_TITLE</title>
    <meta charset="utf-8">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap');
        
        body {
            font-family: 'Inter', sans-serif;
            color: #333;
        }
        
        .remark-slide-content {
            background: #fff;
            padding: 2em 3em;
            font-size: 26px;
            line-height: 1.4;
        }
        
        .title-slide {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .title-slide h1 {
            font-size: 3.5em;
            font-weight: 700;
            margin-bottom: 0.5em;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }
        
        .title-slide h2 {
            font-size: 2em;
            font-weight: 300;
            margin-bottom: 1em;
            opacity: 0.9;
        }
        
        .title-slide h3 {
            font-size: 1.4em;
            font-weight: 400;
            opacity: 0.8;
        }
        
        h1, h2, h3 {
            font-weight: 600;
            margin-top: 0;
            color: #2c3e50;
        }
        
        .title-slide h1, .title-slide h2, .title-slide h3 {
            color: white;
        }
        
        .highlight { background: #ffffcc; padding: 2px 4px; }
        .red { color: #e74c3c; font-weight: 600; }
        .blue { color: #3498db; font-weight: 600; }
        .green { color: #27ae60; font-weight: 600; }
        
        .left-column { float: left; width: 48%; }
        .right-column { float: right; width: 48%; }
        
        .footnote {
            position: absolute;
            bottom: 2em;
            right: 3em;
            font-size: 0.8em;
            opacity: 0.6;
        }
        
        code {
            background: #f8f9fa;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        }
        
        .remark-code {
            font-size: 0.8em;
            line-height: 1.2;
        }
        
        .remark-slide-number {
            font-size: 0.8em;
            opacity: 0.5;
        }
        
        img {
            max-width: 100%;
            height: auto;
        }
        
        blockquote {
            border-left: 4px solid #3498db;
            margin: 1em 0;
            padding-left: 1em;
            font-style: italic;
            background: #f8f9fa;
            padding: 1em;
        }
    </style>
</head>
<body>
    <textarea id="source"></textarea>
    <script src="https://remarkjs.com/downloads/remark-latest.min.js"></script>
    <script>
        // Load markdown content
        fetch('MARKDOWN_FILE.md')
            .then(response => {
                if (!response.ok) {
                    throw new Error(`Failed to load MARKDOWN_FILE.md: ${response.status}`);
                }
                return response.text();
            })
            .then(markdown => {
                document.getElementById('source').value = markdown;
                
                var slideshow = remark.create({
                    highlightStyle: 'github',
                    highlightLines: true,
                    countIncrementalSlides: false,
                    ratio: '16:9'
                });
            })
            .catch(error => {
                console.error('Error loading presentation:', error);
                document.body.innerHTML = `
                    <div style="padding: 2em; font-family: sans-serif;">
                        <h1>Error Loading Presentation</h1>
                        <p>Could not load <code>MARKDOWN_FILE.md</code></p>
                        <p>Make sure the file exists in the same directory as this HTML file.</p>
                        <p style="color: #666;">Error: ${error.message}</p>
                    </div>
                `;
            });
    </script>
</body>
</html>
EOF

# Replace placeholders in HTML file
sed -i '' "s/PRESENTATION_TITLE/${PRESENTATION_TITLE}/g" "${PRESENTATION_NAME}/${PRESENTATION_NAME}.html"
sed -i '' "s/MARKDOWN_FILE/${PRESENTATION_NAME}/g" "${PRESENTATION_NAME}/${PRESENTATION_NAME}.html"

# Create README for the presentation
cat > "${PRESENTATION_NAME}/README.md" << EOF
# ${PRESENTATION_TITLE}

## Presentation Details

- **Title**: ${PRESENTATION_TITLE}
- **Speaker(s)**: [Your Name]
- **Date**: [Presentation Date]
- **Duration**: [Duration]
- **Event**: [Event/Conference Name]

## Abstract

[Brief description of what this presentation covers]

## Structure

1. **Introduction** - Overview and agenda
2. **Main Content** - [Key topics covered]
3. **Conclusion** - Summary and next steps

## Files

- **\`${PRESENTATION_NAME}.html\`** - Main presentation file (open this to view)
- **\`${PRESENTATION_NAME}.md\`** - Markdown source content
- **\`img/\`** - Presentation-specific images and screenshots
- **\`README.md\`** - This documentation file

## Viewing the Presentation

### Option 1: Direct HTML Access
\`\`\`bash
cd ${PRESENTATION_NAME}
open ${PRESENTATION_NAME}.html
\`\`\`

### Option 2: Local Server (Recommended for development)
From the repository root:
\`\`\`bash
python3 -m http.server 8000
# Then visit: http://localhost:8000/${PRESENTATION_NAME}/${PRESENTATION_NAME}.html
\`\`\`

## Presenting

- **Navigate**: Arrow keys, Page Up/Down, or click
- **Fullscreen**: Press \`F\`
- **Presenter Mode**: Press \`P\` (shows current + next slide, timer, notes)
- **Clone View**: Press \`C\` (for dual monitor setup)

## Development Notes

[Add any specific notes about content, styling, or technical requirements]

## Resources

- [Link to event page]
- [Reference materials]
- [Related presentations]
EOF

echo ""
echo "✅ Created presentation: ${PRESENTATION_NAME}/"
echo "   📄 ${PRESENTATION_NAME}/${PRESENTATION_NAME}.md"
echo "   🌐 ${PRESENTATION_NAME}/${PRESENTATION_NAME}.html"
echo "   📁 ${PRESENTATION_NAME}/img/"
echo "   📋 ${PRESENTATION_NAME}/README.md"
echo ""
echo "🚀 To get started:"
echo "   cd ${PRESENTATION_NAME}"
echo "   open ${PRESENTATION_NAME}.html"
echo ""
echo "💡 For development with live reload:"
echo "   python3 -m http.server 8000"
echo "   # Visit: http://localhost:8000/${PRESENTATION_NAME}/${PRESENTATION_NAME}.html" 