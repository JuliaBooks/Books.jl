-- Pandoc drops code block annotations by default.
-- This function manually handles blocks tagged as output.
--
-- Thanks to https://github.com/jgm/pandoc/issues/4116#issuecomment-579426694.
--
local function CodeBlock (elem)
    if elem.c[1][2][1] == "language-julia" then
        return pandoc.RawBlock("latex", "\n\\begin{lstlisting}[language=Julia]\n"..elem.text.."\n\\end{lstlisting}\n")
    elseif elem.c[1][2][1] == "output" then
        return pandoc.RawBlock("latex", "\n\\begin{lstlisting}[language=output]\n"..elem.text.."\n\\end{lstlisting}\n")
    else
        return elem
    end
end

return { { CodeBlock = CodeBlock } }
