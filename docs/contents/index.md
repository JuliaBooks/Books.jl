# Welcome {-}

```{=comment}
This file is only included on the website.
```

```jl
M.homepage_intro()
```

See @sec:about for more information about this package.
To get started and setup your own project, see @sec:getting-started.
You can see a demonstration of the features and usage examples in @sec:demo.

## Maintenance mode

As it stands now (2022-02-01), this project is in maintenance mode.
Feel free to use it, we've sucessfuly published [a book](https://juliadatascience.io/) with it so everything should work.
However, I personally don't believe much more in the approach taken in this project for two reasons:

First, PDFs are overrated.
According to the analytics on our site, only about 10 % of the people who visit download the PDF and only 1 % buys the book.    
On the other hand, HTML is a very versatille format for which robust standards exist.
Compared to PDF, HTML and CSS support:

- accurate copy pasting of text
- adjusting text based on screen width
- adjusting background color based on 

Also, HTML can embed images in the document whereas LaTeX doesn't support this as far as I know.
LaTeX even has trouble with SVG meaning that this package has to add special logic for that.

Second, correctly evaluating code is **hard**.
This package manually has to implement some overrides for `show` for different plotting objects, but is far from complete.
Packages such as Pluto or Jupyter have spent much time on all these overrides too, but managing it all for a books package seems to be too much.

So, instead, my main focus will be [PlutoStaticHTML.jl](https://github.com/rikhuijzer/PlutoStaticHTML.jl) in the near future because it is much more promising.
For example, [Julia Tutorials Template](https://rikhuijzer.github.io/JuliaTutorialsTemplate/).
