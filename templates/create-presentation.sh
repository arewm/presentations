#!/bin/bash

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <date-slug> <title> <event-name>"
    echo "Example: $0 2025-12-01-my-talk \"My Awesome Talk\" \"Conference 2025\""
    exit 1
fi

DATE_SLUG=$1
TITLE=$2
EVENT=$3
PRESENTATION_DIR="_presentations/$DATE_SLUG"

# Extract date from slug (assumes YYYY-MM-DD format at start)
DATE=$(echo $DATE_SLUG | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')

if [ -z "$DATE" ]; then
    echo "Error: Date slug must start with YYYY-MM-DD format"
    exit 1
fi

# Create presentation directory
mkdir -p "$PRESENTATION_DIR/img"

# Create presentation.md
cat > "$PRESENTATION_DIR/presentation.md" << 'EOF'
class: center, middle, title-slide

# TITLE_PLACEHOLDER
## Subtitle
### Author • DATE_PLACEHOLDER

---

## Slide 2

Your content here...

---

## Slide 3

More content...

???
Speaker notes here (visible in presenter mode with 'P')
EOF

# Replace placeholders
sed -i.bak "s/TITLE_PLACEHOLDER/$TITLE/g" "$PRESENTATION_DIR/presentation.md"
sed -i.bak "s/DATE_PLACEHOLDER/$DATE/g" "$PRESENTATION_DIR/presentation.md"
rm "$PRESENTATION_DIR/presentation.md.bak"

# Create index.md with front matter
cat > "$PRESENTATION_DIR/index.md" << EOF
---
title: "$TITLE"
event: "$EVENT"
date: $DATE
slides_path: presentation.md
---

## Abstract

[Add your presentation abstract here]

## Key Topics

- Topic 1
- Topic 2
- Topic 3
EOF

echo "✅ Created presentation: $PRESENTATION_DIR"
echo ""
echo "Next steps:"
echo "1. Edit $PRESENTATION_DIR/presentation.md for your slides"
echo "2. Edit $PRESENTATION_DIR/index.md for abstract and metadata"
echo "3. Add images to $PRESENTATION_DIR/img/"
echo "4. (Optional) Add $PRESENTATION_DIR/custom.css for custom styling"
echo ""
echo "Preview:"
echo "  - Run: bundle exec jekyll serve"
echo "  - Visit: http://localhost:4000/presentations/$(basename $DATE_SLUG)/"
echo "  - Slides: http://localhost:4000/presentations/$(basename $DATE_SLUG)/slides.html"
