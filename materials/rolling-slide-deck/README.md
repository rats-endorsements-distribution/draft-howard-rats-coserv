On Mac:

* install `rsvg-convert`
```
brew install librsvg
```

* install `aasvg`
```
npm install -g aasvg
```

* transform the ASCII diagrams into PDF images
```
make
```

* render the presentation
```
open -a /Applications/Deckset.app main.md
```

When you edit the markdown file the rendering will automatically refresh.
