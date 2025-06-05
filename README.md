# Presentations

Source controlled presentations using Remark.js and Markdown in dedicated directories with individual HTML files.

## Overview

This repository provides a system for creating and maintaining presentations using:
- **Markdown** for content (easy to write and version control)
- **Directory-based organization** with individual HTML files for each presentation
- **Remark.js** for rendering beautiful HTML slides
- **Git** for version control and collaboration
- **Reusable templates** and shared assets

## Quick Start

### 1. Create Your First Presentation

```bash
# Create a new presentation with starter content and structure
./templates/create-presentation.sh 2025-12-01-my-awesome-talk "My Awesome Talk"

# This creates:
# 2025-12-01-my-awesome-talk/
#   ├── my-awesome-talk.md         # Your content
#   ├── my-awesome-talk.html       # HTML viewer (loads markdown automatically)
#   ├── img/                       # Presentation-specific images
#   └── README.md                  # Documentation and notes
```

### 2. Develop Your Content

```bash
cd 2025-12-01-my-awesome-talk
# Edit the markdown file with your slides
vim my-awesome-talk.md

# Preview by opening the HTML file
open my-awesome-talk.html
```

### 3. Present

Simply open your HTML file: `open 2025-12-01-my-awesome-talk/my-awesome-talk.html`

**Presentation Controls:**
- **Navigate**: Arrow keys, Page Up/Down, or click
- **Fullscreen**: Press `F`
- **Presenter Mode**: Press `P` (shows current + next slide, timer, notes)
- **Clone View**: Press `C` (for dual monitor setup)

## Directory Structure

Each presentation is self-contained in its own directory.

```
presentations/
├── 2024-04-16-let-devs-be-devs/   # Individual presentation directories
│   ├── let-devs-be-devs.md        # Markdown slides
│   ├── let-devs-be-devs.html      # HTML viewer
│   ├── img/                       # Presentation images
│   └── README.md                  # Documentation
├── shared/
│   └── images/                    # Shared images across presentations
├── templates/
│   ├── create-presentation.sh     # Creation script
│   └── template.html              # Generic template
└── examples/
    └── sample-presentation.md     # Feature examples
```

## Writing Presentations

### Basic Slide Structure

```markdown
class: center, middle, title-slide

# Main Title
## Subtitle
### Author • Date

---

## Regular Slide

Content goes here...

---

# Next Slide

More content...
```

### Advanced Features

- **Text Styling**: `.red[text]`, `.highlight[text]`, `.blue[text]`
- **Two-Column Layouts**: `.left-column[]` and `.right-column[]`
- **Code Syntax Highlighting**: \`\`\`python code blocks
- **Images**: `![Alt text](img/image.png)` or `![Shared](../shared/images/logo.png)`
- **Speaker Notes**: `???` followed by notes (visible in presenter mode)
- **Footnotes**: `.footnote[text]`

See `examples/sample-presentation.md` for complete examples.

## Presentation Workflow

### Development
1. **Create**: `./templates/create-presentation.sh presentation-name`
2. **Edit**: Modify the `.md` file with your content
3. **Preview**: Open the `.html` file in your browser
4. **Iterate**: Edit markdown, refresh browser

### Assets Management
- **Presentation-specific images**: Save to `presentation-name/img/`
- **Shared images**: Use `shared/images/` for logos, common diagrams
- **Reference from markdown**: `![Image](img/screenshot.png)` or `![Logo](../shared/images/company-logo.png)`

### Collaboration
```bash
# Work on presentations in branches
git checkout -b presentation/my-new-talk
git add my-new-talk/
git commit -m "Add new presentation: My New Talk"
git push origin presentation/my-new-talk
```

## Benefits of This Approach

✅ **Self-Contained**: Each presentation directory is fully portable with all assets  
✅ **Direct HTML Access**: No server required, works offline  
✅ **Version Control**: Track changes to both content and styling  
✅ **Shared Assets**: Reuse common images and resources  
✅ **Template Updates**: Consistent styling across presentations  
✅ **Documentation**: Each presentation documents its own purpose and structure

## Converting from PowerPoint/Google Slides

### PowerPoint to Markdown (Recommended)

Use [pptx2md](https://github.com/ssine/pptx2md) for automated conversion:

```bash
# Install pptx2md
pipx install pptx2md

# Convert PowerPoint to markdown
pptx2md presentation.pptx -o converted-presentation.md -i img --enable-slides

# Create presentation directory
mkdir converted-presentation
mv converted-presentation.md converted-presentation/
mv img/ converted-presentation/

# Create HTML viewer
cp templates/template.html converted-presentation/converted-presentation.html
# Edit to replace MARKDOWN_FILE with "converted-presentation"
```

**Benefits of pptx2md:**
- ✅ Preserves all text formatting (bold, italic, colors)
- ✅ Extracts all images automatically
- ✅ Maintains slide structure with `---` separators
- ✅ Includes speaker notes
- ✅ Handles tables and lists properly

### Manual Migration from Google Slides

1. **Extract content**: Copy text content slide by slide
2. **Download images**: Save to `presentation-name/img/`
3. **Convert formatting**: Use markdown syntax and CSS classes
4. **Test presentation**: Preview frequently during conversion

## Deployment Options

### Local Development
```bash
# Serve locally for testing and development
python -m http.server 8000
# Visit: http://localhost:8000/2024-04-16-let-devs-be-devs/let-devs-be-devs.html
```

### GitHub Pages
1. Enable GitHub Pages in repository settings
2. Your presentations will be available at:
   `https://username.github.io/presentations/2024-04-16-let-devs-be-devs/let-devs-be-devs.html`

### File Sharing
- Individual HTML files work offline
- Share entire presentation folder for offline viewing
- No server required for basic functionality

## Resources

- [Remark.js Documentation](https://remarkjs.com/)
- [Markdown Guide](https://www.markdownguide.org/)
- **Examples**: Check `examples/sample-presentation.md` for all features
- **Structure**: See `STRUCTURE.md` for detailed organization guide

---

**Happy presenting!** 🎉

*This system gives you the power of version control with the simplicity of individual HTML files for each presentation.*
