# Question content and PowerPoint

Edit `questions.json` to update the question review shown on the website. The same data builds the downloadable PowerPoint, so both versions stay in sync.

From the repository root, run:

```powershell
python tools/build_questions_pptx.py
```

The generated deck is `ancient-greece-questions.pptx`.
