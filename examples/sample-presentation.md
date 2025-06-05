class: center, middle, title-slide

# Sample Presentation

## A Template for Your Presentations

### Using Remark.js and Markdown

---

## What is This?

This is a **presentation system** that allows you to:

- Write presentations in `.red[Markdown]`
- Store them in version control
- Share and reuse content easily
- Present directly in the browser

.footnote[Navigate with arrow keys or click]

---

## Key Features

### 🎨 Styling
- Beautiful, responsive design
- Syntax highlighting for code
- Custom CSS classes available

### 📝 Markdown Support
- Standard markdown syntax
- Code blocks with highlighting
- Images and links

### 🔄 Version Control
- Track changes over time
- Collaborate with others
- Branch for different versions

---

## Code Example

Here's some sample code with syntax highlighting:

```javascript
function createPresentation(source) {
  return remark.create({
    sourceUrl: source,
    highlightStyle: 'monokai',
    ratio: '16:9'
  });
}
```

```python
def hello_world():
    print("Hello from your presentation!")
    return "Ready to present!"
```

---

## Two Column Layout

.two-columns[
.column[
### Left Column
- First point
- Second point
- Third point

This is useful for:
- Comparisons
- Before/after
- Pros and cons
]

.column[
### Right Column
- Another point
- Different perspective
- Complementary info

You can include:
- Images
- Code snippets
- Bullet points
]
]

---

## Text Styling

You can use various text styles:

- .red[Red text]
- .blue[Blue text] 
- .green[Green text]
- .highlight[Highlighted text]
- .large[Large text]
- .medium[Medium text]
- .small[Small text]

---

## How to Use This System

1. **Create a new markdown file** for your presentation
   ```
   my-awesome-presentation.md
   ```

2. **View it in the browser** using the template:
   ```
   template.html?source=my-awesome-presentation.md
   ```

3. **Write your slides** using markdown with `---` as slide separators

4. **Version control everything** with git

---

class: center, middle

## Ready to Create?

### Copy `template.html` to `your-presentation.html`
### Create `your-presentation.md` 
### Start presenting!

.footnote[
🎯 **Tip**: You can copy the template for each presentation or use the same template with different source parameters
]

---

class: center, middle

# Questions?

### Happy Presenting! 🎉 