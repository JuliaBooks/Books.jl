-- Pandoc drops code block annotations by default.
-- This function manually handles blocks tagged as output.
--
-- Thanks to https://github.com/jgm/pandoc/issues/4116#issuecomment-579426694.
-- Thanks to https://github.com/jgm/pandoc/issues/4116#issuecomment-1020677402 for support of pandoc >= 2.16
--
local function CodeBlock (elem)
    if elem.classes[1] == "language-julia" then
        return pandoc.RawBlock("latex", "\n\\begin{lstlisting}[language=Julia]\n"..elem.text.."\n\\end{lstlisting}\n")
    elseif elem.classes[1] == "output" then
        return pandoc.RawBlock("latex", "\n\\begin{lstlisting}[language=Output]\n"..elem.text.."\n\\end{lstlisting}\n")
    else
        return elem
    end
end

return { { CodeBlock = CodeBlock } }
