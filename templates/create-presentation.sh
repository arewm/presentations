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
if [ ! -d ".git" ] || [ ! -d "templates" ]; then
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
cp templates/template.html "${PRESENTATION_NAME}/${PRESENTATION_NAME}.html"

# Replace placeholders in HTML file
sed -i '' "s/PRESENTATION_TITLE/${PRESENTATION_TITLE}/g" "${PRESENTATION_NAME}/${PRESENTATION_NAME}.html"
sed -i '' "s/MARKDOWN_FILE/${PRESENTATION_NAME}/g" "${PRESENTATION_NAME}/${PRESENTATION_NAME}.html"

# Create README for the presentation
cat > "${PRESENTATION_NAME}/README.md" << EOF
# ${PRESENTATION_TITLE}

**[Event/Conference Name]**

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