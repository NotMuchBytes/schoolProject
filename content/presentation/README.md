# Presentation content

The browser does not render `.pptx` files reliably. Export the PowerPoint slides as PNG or JPG images instead.

1. In PowerPoint, choose **File → Export → Change File Type → PNG** (or JPG), then export every slide.
2. Copy the generated images into `content/presentation/slides/`.
3. Edit `content/presentation/manifest.json` so each slide appears in order:

```json
{
  "title": "Lesson title",
  "slides": [
    { "src": "slides/slide-01.png", "alt": "Description of slide 1" },
    { "src": "slides/slide-02.png", "alt": "Description of slide 2" }
  ]
}
```

The viewer automatically provides previous/next controls, slide numbering, keyboard navigation, responsive scaling, and fullscreen mode.
